import SwiftUI
import SwiftData

@main
struct iOS_ConferencesApp: App {
    @State private var calendarService = CalendarService()
    @State private var tipJarService = TipJarService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(calendarService)
                .environment(tipJarService)
        }
        .modelContainer(for: [Conference.self, FavouriteConference.self]) { result in
            if case .success(let container) = result {
                Task { @MainActor in
                    let service = ConferenceServiceFactory.make()
                    try? await service.refreshCache(into: container.mainContext)
                }
            }
        }
    }
}
