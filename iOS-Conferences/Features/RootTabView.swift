import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Conferences", systemImage: "calendar") {
                ConferenceListView(filter: .all)
            }
            Tab("Favourites", systemImage: "heart") {
                ConferenceListView(filter: .favourites)
            }
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
