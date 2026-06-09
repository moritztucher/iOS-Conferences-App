import SwiftUI

/// Month-sectioned, inset-grouped list of conferences with a trailing favourite
/// swipe action. Shared by the Conferences/Favourites tabs and the Search tab so
/// every entry point renders rows identically. The host supplies the favourite
/// toggle and owns the `NavigationStack` + `navigationDestination`.
struct ConferenceSectionList: View {
    let sections: [ConferenceMonthSection]
    let favouriteIDs: Set<String>
    /// Shared with the host's `navigationDestination` so tapping a card zooms into the
    /// detail hero (`.navigationTransition(.zoom(sourceID:in:))`).
    let namespace: Namespace.ID
    let onToggleFavourite: (Conference) -> Void

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.title) {
                    ForEach(section.conferences) { conference in
                        ConferenceCard(
                            conference: conference,
                            isFavourite: favouriteIDs.contains(conference.id)
                        )
                        .matchedTransitionSource(id: conference.id, in: namespace)
                        // Full-card tap target without the List's NavigationLink chevron,
                        // which would break the full-bleed card edge.
                        .background {
                            NavigationLink(value: Route.conferenceDetail(conferenceID: conference.id)) {
                                Color.clear
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            favouriteSwipeAction(for: conference)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func favouriteSwipeAction(for conference: Conference) -> some View {
        let isFavourite = favouriteIDs.contains(conference.id)
        Button {
            onToggleFavourite(conference)
        } label: {
            Label(
                isFavourite ? "Unfavourite" : "Favourite",
                systemImage: isFavourite ? "heart.slash.fill" : "heart.fill"
            )
        }
        .tint(isFavourite ? .gray : .pink)
    }
}
