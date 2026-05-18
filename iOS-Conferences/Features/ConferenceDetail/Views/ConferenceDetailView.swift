import SwiftUI
import SwiftData

struct ConferenceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarService.self) private var calendarService
    @Query private var favourites: [FavouriteConference]

    @State private var viewModel: ConferenceDetailViewModel

    init(conference: Conference) {
        _viewModel = State(initialValue: ConferenceDetailViewModel(conference: conference))
    }

    private var isFavourite: Bool {
        viewModel.isFavourite(in: favourites)
    }

    var body: some View {
        @Bindable var bindable = viewModel
        Form {
            whenAndWhereSection
            aboutSection
            actionsSection
        }
        .navigationTitle(viewModel.conference.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $bindable.isShowingSafari) {
            if let url = viewModel.conference.websiteURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $bindable.isShowingEventEditor) {
            EventEditorView(
                event: calendarService.makeDraftEvent(for: viewModel.conference),
                eventStore: calendarService.eventStore
            )
            .ignoresSafeArea()
        }
        .alert(
            item: $bindable.calendarAccessIssue
        ) { issue in
            switch issue {
            case .denied:
                return Alert(
                    title: Text(issue.title),
                    message: Text(issue.message),
                    primaryButton: .default(Text("Open Settings"), action: viewModel.openAppSettings),
                    secondaryButton: .cancel()
                )
            case .restricted:
                return Alert(
                    title: Text(issue.title),
                    message: Text(issue.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    @ViewBuilder
    private var whenAndWhereSection: some View {
        Section("When & Where") {
            LabeledContent {
                Text(ConferenceDateStyle.range(from: viewModel.conference.startDate, to: viewModel.conference.endDate))
                    .foregroundStyle(.secondary)
            } label: {
                Label("Date", systemImage: "calendar")
            }

            if viewModel.conference.isOnline {
                LabeledContent {
                    Text("Online").foregroundStyle(.secondary)
                } label: {
                    Label("Format", systemImage: "globe")
                }
            } else {
                Button {
                    viewModel.openInMaps()
                } label: {
                    LabeledContent {
                        HStack(spacing: 4) {
                            Text(viewModel.conference.locationName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .imageScale(.small)
                                .foregroundStyle(.tertiary)
                        }
                    } label: {
                        Label("Location", systemImage: "mappin.and.ellipse")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens in Maps")
            }
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        if !viewModel.conference.summary.isEmpty {
            Section("About") {
                Text(viewModel.conference.summary)
                    .foregroundStyle(.primary)
            }
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        Section {
            Button {
                viewModel.isShowingSafari = true
            } label: {
                Label("Visit website", systemImage: "safari")
            }
            .disabled(viewModel.conference.websiteURL == nil)

            Button {
                Task { await viewModel.requestCalendarAccess(via: calendarService) }
            } label: {
                Label("Add to calendar", systemImage: "calendar.badge.plus")
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.toggleFavourite(in: favourites, context: modelContext)
            } label: {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .symbolEffect(.bounce, value: isFavourite)
            }
            .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
        }
        ToolbarItem(placement: .topBarTrailing) {
            ShareLink(item: viewModel.shareText)
        }
    }
}

#Preview {
    NavigationStack {
        ConferenceDetailView(conference: .sample)
    }
    .modelContainer(PreviewContainer.shared)
    .environment(CalendarService())
}
