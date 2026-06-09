import SwiftUI
import SwiftData

/// Content for the global `Tab(role: .search)`, which iOS 26 renders as a dedicated
/// search affordance in the tab bar. Hosts its own search field and renders matches
/// for the query across every conference, reusing `ConferenceListViewModel`'s
/// filtering and the shared `ConferenceSectionList` so results look identical to the
/// main list.
struct ConferenceSearchView: View {
    @Query(sort: \Conference.startDate) private var conferences: [Conference]
    @Query private var favourites: [FavouriteConference]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("settings.showPastConferences") private var showPastConferences = false

    @State private var viewModel = ConferenceListViewModel(filter: .all)
    @State private var path = NavigationPath()
    @Namespace private var namespace

    private var favouriteIDs: Set<String> {
        Set(favourites.map(\.conferenceID))
    }

    private var trimmedQuery: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var sections: [ConferenceMonthSection] {
        viewModel.sections(
            from: conferences,
            favouriteIDs: favouriteIDs,
            showPast: showPastConferences
        )
    }

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack(path: $path) {
            content
                .navigationTitle("Search")
                .searchable(text: $bindable.searchText)
                .navigationDestination(for: Route.self) { route in
                    routeDestination(for: route)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if trimmedQuery.isEmpty {
            ContentUnavailableView(
                "Search Conferences",
                systemImage: "magnifyingglass",
                description: Text("Find a conference by name, location, or tag.")
            )
        } else if sections.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
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
}

#Preview {
    ConferenceSearchView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
}
