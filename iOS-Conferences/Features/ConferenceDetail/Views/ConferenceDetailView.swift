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
        List {
            heroSection
            titleSection
            whenAndWhereSection
            aboutSection
            actionsSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.conference.name)
        .navigationBarTitleDisplayMode(.inline)
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
        .alert(item: $bindable.calendarAccessIssue) { issue in
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

    // MARK: - Sections

    @ViewBuilder
    private var heroSection: some View {
        Section {
            ConferenceHeroBanner(conference: viewModel.conference)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var titleSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.conference.name)
                    .font(.title2.weight(.semibold))
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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

    // MARK: - Helpers

    private var headerSubtitle: String {
        let range = ConferenceDateStyle.range(from: viewModel.conference.startDate, to: viewModel.conference.endDate)
        return "\(range) · \(viewModel.conference.locationShort)"
    }
}

struct ConferenceHeroBanner: View {
    let conference: Conference

    var body: some View {
        AsyncImage(url: conference.logoURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                ConferencePlaceholder(conference: conference)
            @unknown default:
                ConferencePlaceholder(conference: conference)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipped()
        .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        ConferenceDetailView(conference: .sample)
    }
    .modelContainer(PreviewContainer.shared)
    .environment(CalendarService())
}
