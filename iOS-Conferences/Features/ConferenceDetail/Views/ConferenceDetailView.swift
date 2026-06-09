import SwiftUI
import SwiftData
import MapKit

struct ConferenceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarService.self) private var calendarService
    @Query private var favourites: [FavouriteConference]

    @State private var viewModel: ConferenceDetailViewModel
    /// The conference name lives in the large title block under the hero; it only
    /// appears in the navigation bar once that block has scrolled out of view, so
    /// the name is never shown twice at rest.
    @State private var showsNavBarTitle = false

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
            mapSection
            whenAndWhereSection
            aboutSection
        }
        .listStyle(.insetGrouped)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) { bottomActionBar }
        .task(id: viewModel.conference.id) { await viewModel.resolveVenue() }
        .navigationTitle(showsNavBarTitle ? viewModel.conference.name : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(showsNavBarTitle ? .automatic : .hidden, for: .navigationBar)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            // The name lives in the hero overlay; reveal the nav-bar title once the hero
            // has mostly scrolled away.
            geometry.contentOffset.y > ConferenceDetailHero.baseHeight - 80
        } action: { _, isPastTitle in
            showsNavBarTitle = isPastTitle
        }
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
            ConferenceDetailHero(conference: viewModel.conference)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var mapSection: some View {
        if let coordinate = viewModel.venueCoordinate {
            Section {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )) {
                    Marker(viewModel.conference.locationShort, coordinate: coordinate)
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
                .allowsHitTesting(false)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .contentShape(.rect)
                .onTapGesture { viewModel.openInMaps() }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Map of \(viewModel.conference.locationName)")
                .accessibilityHint("Opens in Maps")
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
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

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.isShowingSafari = true
            } label: {
                Label("Website", systemImage: "safari")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 26)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.conference.websiteURL == nil)
            .accessibilityLabel("Visit website")

            Button {
                Task { await viewModel.requestCalendarAccess(via: calendarService) }
            } label: {
                Label("Calendar", systemImage: "calendar.badge.plus")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 26)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Add to calendar")
        }
        .labelStyle(.titleAndIcon)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.bar)
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
            if let url = viewModel.conference.websiteURL {
                ShareLink(
                    item: url,
                    subject: Text(viewModel.conference.name),
                    message: Text(viewModel.shareText),
                    preview: SharePreview(viewModel.conference.name)
                )
            } else {
                ShareLink(item: viewModel.shareText)
            }
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
