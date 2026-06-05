import SwiftUI
import SwiftData

struct RootTabView: View {
    @Query private var favourites: [FavouriteConference]

    var body: some View {
        TabView {
            Tab("Conferences", systemImage: "calendar") {
                ConferenceListView(filter: .all)
            }
            Tab("Favourites", systemImage: "heart") {
                ConferenceListView(filter: .favourites)
            }
            .badge(favourites.count)
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
            Tab(role: .search) {
                ConferenceSearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
}
