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
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
        .environment(TipJarService.preview())
}
