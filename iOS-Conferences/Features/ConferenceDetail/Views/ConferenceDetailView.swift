import SwiftUI
import SwiftData
import MapKit

struct ConferenceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarService.self) private var calendarService
    @Environment(AchievementService.self) private var achievements
    @Query private var favourites: [FavouriteConference]

    @State private var viewModel: ConferenceDetailViewModel
    /// The conference name lives in the hero title block; it only appears in the navigation
    /// bar once that block has scrolled out of view, so the name is never shown twice at rest.
    @State private var showsNavBarTitle = false

    init(conference: Conference) {
        _viewModel = State(initialValue: ConferenceDetailViewModel(conference: conference))
    }

    private var isFavourite: Bool {
        viewModel.isFavourite(in: favourites)
    }

    var body: some View {
        @Bindable var bindable = viewModel
        ScrollView {
            VStack(spacing: 16) {
                ConferenceDetailHero(conference: viewModel.conference)
                contentCards
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(edges: .top)
        // The detail is an immersive leaf screen: hide the tab bar so the full-bleed hero
        // and the pinned action bar own the bottom edge (the bar returns on pop).
        .toolbarVisibility(.hidden, for: .tabBar)
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
        .sensoryFeedback(trigger: isFavourite) { _, isNowFavourite in
            isNowFavourite ? .success : .impact(weight: .light)
        }
        .sensoryFeedback(trigger: viewModel.isShowingEventEditor) { _, isPresented in
            isPresented ? .impact(weight: .medium) : nil
        }
        .sensoryFeedback(.error, trigger: viewModel.calendarAccessIssue != nil) { _, hasIssue in
            hasIssue
        }
        .sheet(isPresented: $bindable.isShowingSafari) {
            if let url = viewModel.conference.websiteURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $bindable.isShowingEventEditor) {
            EventEditorView(
                event: calendarService.makeDraftEvent(
                    for: viewModel.conference,
                    timeZone: viewModel.venueTimeZone
                ),
                eventStore: calendarService.eventStore,
                onSaved: { achievements.record(.addedToCalendar) }
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

    // MARK: - Content cards

    /// Floating glass cards (ADR-0007) replacing the stock grouped `Form` sections — they
    /// continue the ticket identity from the hero instead of dropping onto a generic list.
    private var contentCards: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 16) {
                if !viewModel.conference.summary.isEmpty {
                    GlassSectionCard(title: "About") {
                        Text(viewModel.conference.summary)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                GlassSectionCard(title: "When & Where") {
                    whenAndWhereContent
                }
            }
        }
    }

    @ViewBuilder
    private var whenAndWhereContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            dateRow
            if viewModel.conference.isTimed {
                Divider()
                timeRow
            }
            Divider()
            if viewModel.conference.isOnline {
                onlineRow
            } else {
                locationRow
            }
            if let coordinate = viewModel.venueCoordinate {
                mapView(for: coordinate)
            }
        }
    }

    // MARK: - Rows

    private func rowIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.body)
            .foregroundStyle(Theme.accent)
            .frame(width: 24, alignment: .center)
            .accessibilityHidden(true)
    }

    /// Date with a relative countdown beneath it, so the row adds information the hero's
    /// date line doesn't already carry.
    private var dateRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            rowIcon("calendar")
            Text("Date")
            Spacer(minLength: 12)
            VStack(alignment: .trailing, spacing: 2) {
                Text(ConferenceDateStyle.range(from: viewModel.conference.startDate, to: viewModel.conference.endDate))
                    .foregroundStyle(.secondary)
                if let countdown = ConferenceDateStyle.countdown(
                    from: viewModel.conference.startDate,
                    to: viewModel.conference.endDate
                ) {
                    Text(countdown)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .multilineTextAlignment(.trailing)
        }
    }

    /// Wall-clock time for Watch Parties / Events, with the zone abbreviation when known.
    private var timeRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            rowIcon("clock")
            Text("Time")
            Spacer(minLength: 12)
            Text(timeText).foregroundStyle(.secondary)
        }
    }

    private var timeText: String {
        guard let start = viewModel.conference.startTimeMinutes else { return "" }
        var text = ConferenceDateStyle.timeRangeLabel(start: start, end: viewModel.conference.endTimeMinutes)
        if let abbreviation = viewModel.conference.timeZoneAbbreviation {
            text += " \(abbreviation)"
        }
        return text
    }

    private var onlineRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            rowIcon("globe")
            Text("Format")
            Spacer(minLength: 12)
            Text("Online").foregroundStyle(.secondary)
        }
    }

    private var locationRow: some View {
        Button {
            viewModel.openInMaps()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                rowIcon("mappin.and.ellipse")
                Text("Location").foregroundStyle(.primary)
                Spacer(minLength: 12)
                Text(viewModel.conference.locationName)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens in Maps")
    }

    /// Venue map rounded inside the card, with a material badge making the tap-through explicit.
    private func mapView(for coordinate: CLLocationCoordinate2D) -> some View {
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
        .frame(height: 160)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.forward")
                Text("Open in Maps")
            }
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: Capsule())
            .padding(10)
        }
        .contentShape(.rect)
        .onTapGesture { viewModel.openInMaps() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map of \(viewModel.conference.locationName)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Opens in Maps")
    }

    // MARK: - Actions

    /// Floating Liquid Glass action bar (ADR-0007): neutral glass Website + accent-tinted
    /// prominent Calendar, blended in a `GlassEffectContainer` over the scrolling content.
    private var bottomActionBar: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    achievements.record(.visitedWebsite)
                    viewModel.isShowingSafari = true
                } label: {
                    Label("Website", systemImage: "safari")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 26)
                }
                .buttonStyle(.glass)
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
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .accessibilityLabel("Add to calendar")
            }
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.toggleFavourite(in: favourites, context: modelContext)
                achievements.reevaluateFavourites()
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
