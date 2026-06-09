import SwiftUI
import SwiftData

struct ConferenceListView: View {
    @Query(sort: \Conference.startDate) private var conferences: [Conference]
    @Query private var favourites: [FavouriteConference]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("settings.showPastConferences") private var showPastConferences = false
    @State private var viewModel: ConferenceListViewModel
    @State private var path = NavigationPath()
    @Namespace private var namespace

    init(filter: ConferenceListViewModel.Filter) {
        _viewModel = State(initialValue: ConferenceListViewModel(filter: filter))
    }

    private var favouriteIDs: Set<String> {
        Set(favourites.map(\.conferenceID))
    }

    private var sections: [ConferenceMonthSection] {
        viewModel.sections(
            from: conferences,
            favouriteIDs: favouriteIDs,
            showPast: showPastConferences
        )
    }

    private var isFiltering: Bool {
        viewModel.isFilterActive || viewModel.isRegionFilterActive || showPastConferences
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                // Conferences tab: drop the large title (redundant with the tab bar label)
                // so the month header leads. Favourites keeps its title.
                .navigationTitle(viewModel.filter == .all ? "" : viewModel.filter.title)
                .navigationBarTitleDisplayMode(viewModel.filter == .all ? .inline : .large)
                .refreshable { await refresh() }
                .toolbar { toolbarContent }
                .navigationDestination(for: Route.self) { route in
                    routeDestination(for: route)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if sections.isEmpty {
            emptyState
        } else {
            ConferenceSectionList(
                sections: sections,
                favouriteIDs: favouriteIDs,
                namespace: namespace,
                onToggleFavourite: { conference in
                    viewModel.toggleFavourite(conference, in: favourites, context: modelContext)
                }
            )
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.filter == .favourites {
            ContentUnavailableView(
                "No Favourites",
                systemImage: "heart",
                description: Text("Tap the heart on a conference to keep it here.")
            )
        } else if isFiltering {
            ContentUnavailableView(
                "No Matches",
                systemImage: "line.3.horizontal.decrease",
                description: Text("No conferences match your current filter.")
            )
        } else {
            ContentUnavailableView(
                "No Conferences",
                systemImage: "calendar",
                description: Text("Pull down to refresh.")
            )
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { regionMenu }
        ToolbarItem(placement: .topBarTrailing) { filterMenu }
    }

    private var filterMenu: some View {
        Menu {
            Group {
                Toggle(isOn: $showPastConferences) {
                    Label("Include past conferences", systemImage: "clock.arrow.circlepath")
                }
                Section("Kind") {
                    ForEach(ConferenceKind.allCases, id: \.self) { kind in
                        Toggle(isOn: kindBinding(kind)) {
                            Label(kind.pluralLabel, systemImage: kind.symbolName)
                        }
                    }
                }
                Picker(selection: $viewModel.formatFilter) {
                    ForEach(ConferenceFormatFilter.allCases) { option in
                        Label(option.label, systemImage: option.systemImage).tag(option)
                    }
                } label: {
                    Label("Format", systemImage: "globe")
                }
            }
            // Applied to the menu's content (not the container) so multi-select toggles
            // keep the menu open instead of dismissing on each tap.
            .menuActionDismissBehavior(.disabled)
        } label: {
            Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Filter")
    }

    private var regionMenu: some View {
        Menu {
            Group {
                Button {
                    viewModel.selectedRegions.removeAll()
                } label: {
                    Label("Global", systemImage: "globe")
                }
                Section("Region") {
                    ForEach(ConferenceRegion.allCases) { region in
                        Toggle(isOn: regionBinding(region)) {
                            Label(region.rawValue, systemImage: region.systemImage)
                        }
                    }
                }
            }
            .menuActionDismissBehavior(.disabled)
        } label: {
            Image(systemName: viewModel.isRegionFilterActive ? "globe.americas.fill" : "globe.americas")
        }
        .accessibilityLabel("Region")
    }

    private func kindBinding(_ kind: ConferenceKind) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedKinds.contains(kind) },
            set: { isOn in
                if isOn { viewModel.selectedKinds.insert(kind) } else { viewModel.selectedKinds.remove(kind) }
            }
        )
    }

    private func regionBinding(_ region: ConferenceRegion) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedRegions.contains(region) },
            set: { isOn in
                if isOn { viewModel.selectedRegions.insert(region) } else { viewModel.selectedRegions.remove(region) }
            }
        )
    }

    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .conferenceDetail(let id):
            if let conference = conferences.first(where: { $0.id == id }) {
                ConferenceDetailView(conference: conference)
                    .navigationTransition(.zoom(sourceID: id, in: namespace))
            } else {
                ContentUnavailableView(
                    "Not Found",
                    systemImage: "questionmark.circle",
                    description: Text("This conference is no longer in the feed.")
                )
            }
        }
    }

    private func refresh() async {
        let service = ConferenceServiceFactory.make()
        try? await service.refreshCache(into: modelContext)
    }
}

#Preview("All") {
    ConferenceListView(filter: .all)
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
}

#Preview("Favourites") {
    ConferenceListView(filter: .favourites)
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
}
