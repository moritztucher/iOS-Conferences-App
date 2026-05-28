import SwiftUI
import SwiftData

struct ConferenceListView: View {
    @Query(sort: \Conference.startDate) private var conferences: [Conference]
    @Query private var favourites: [FavouriteConference]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("settings.showPastConferences") private var showPastConferences = false
    @State private var viewModel: ConferenceListViewModel
    @State private var path = NavigationPath()

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
        viewModel.isFilterActive || showPastConferences
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle(viewModel.filter.title)
                .searchable(text: $viewModel.searchText)
                .refreshable { await refresh() }
                .toolbar { filterToolbarItem }
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
            List {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.conferences) { conference in
                            NavigationLink(value: Route.conferenceDetail(conferenceID: conference.id)) {
                                ConferenceRow(
                                    conference: conference,
                                    isFavourite: favouriteIDs.contains(conference.id)
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if !viewModel.searchText.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else if viewModel.filter == .favourites {
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
    private var filterToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Toggle(isOn: $showPastConferences) {
                    Label("Include past conferences", systemImage: "clock.arrow.circlepath")
                }
                Picker(selection: $viewModel.kindFilter) {
                    ForEach(ConferenceKindFilter.allCases) { option in
                        Label(option.label, systemImage: option.systemImage).tag(option)
                    }
                } label: {
                    Label("Kind", systemImage: "rectangle.stack")
                }
                Picker(selection: $viewModel.formatFilter) {
                    ForEach(ConferenceFormatFilter.allCases) { option in
                        Label(option.label, systemImage: option.systemImage).tag(option)
                    }
                } label: {
                    Label("Format", systemImage: "globe")
                }
            } label: {
                Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
            .menuActionDismissBehavior(.disabled)
            .accessibilityLabel("Filter")
        }
    }

    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .conferenceDetail(let id):
            if let conference = conferences.first(where: { $0.id == id }) {
                ConferenceDetailView(conference: conference)
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
