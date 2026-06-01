import SwiftUI

/// Month-sectioned, inset-grouped list of conferences with a trailing favourite
/// swipe action. Shared by the Conferences/Favourites tabs and the Search tab so
/// every entry point renders rows identically. The host supplies the favourite
/// toggle and owns the `NavigationStack` + `navigationDestination`.
struct ConferenceSectionList: View {
    let sections: [ConferenceMonthSection]
    let favouriteIDs: Set<String>
    let onToggleFavourite: (Conference) -> Void

    var body: some View {
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            favouriteSwipeAction(for: conference)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
