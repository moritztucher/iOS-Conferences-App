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
            titleSection
            mapSection
            whenAndWhereSection
            aboutSection
            actionsSection
        }
        .listStyle(.insetGrouped)
        .task(id: viewModel.conference.id) { await viewModel.resolveVenue() }
        .lookAroundViewer(isPresented: $bindable.isShowingLookAround, initialScene: viewModel.lookAroundScene)
        .navigationTitle(showsNavBarTitle ? viewModel.conference.name : "")
        .navigationBarTitleDisplayMode(.inline)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            // Hero (180pt) + title block scrolls past ~190pt.
            geometry.contentOffset.y > 190
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
    private var mapSection: some View {
        if let coordinate = viewModel.venueCoordinate {
            Section {
                ZStack(alignment: .bottomLeading) {
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

                    if viewModel.lookAroundScene != nil {
                        Button {
                            viewModel.isShowingLookAround = true
                        } label: {
                            Label("Look Around", systemImage: "binoculars.fill")
                                .font(.footnote.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .padding(10)
                    }
                }
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
