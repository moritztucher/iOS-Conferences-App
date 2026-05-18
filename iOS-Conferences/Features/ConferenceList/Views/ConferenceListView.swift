import SwiftUI
import SwiftData

struct ConferenceListView: View {
    @Query(sort: \Conference.startDate) private var conferences: [Conference]
    @Query private var favourites: [FavouriteConference]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("settings.showPastConferences") private var showPastConferences = false
    @State private var viewModel: ConferenceListViewModel
    @State private var path = NavigationPath()
    @State private var isRefreshing = false

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

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle(viewModel.filter.title)
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
                .refreshable {
                    await refresh()
                }
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
        } else {
            ContentUnavailableView(
                "No Conferences",
                systemImage: "calendar",
                description: Text("Pull down to refresh.")
            )
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
        .environment(TipJarService.preview())
}

#Preview("Favourites") {
    ConferenceListView(filter: .favourites)
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
        .environment(TipJarService.preview())
}
