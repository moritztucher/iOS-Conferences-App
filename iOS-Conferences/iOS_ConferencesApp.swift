import SwiftUI
import SwiftData

@main
struct iOS_ConferencesApp: App {
    @State private var calendarService = CalendarService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(calendarService)
        }
        .modelContainer(for: [Conference.self, FavouriteConference.self]) { result in
            if case .success(let container) = result {
                Task { @MainActor in
                    // First-launch instant seed from the bundled list — offline-safe,
                    // no network wait before the UI has something to show.
                    try? await BundledConferenceService().refreshCache(into: container.mainContext)
                    // Background refresh from the live JSON feed. Silently no-ops if
                    // the network is unreachable or the file 404s; the bundled seed
                    // remains as the displayed cache.
                    try? await ConferenceServiceFactory.make().refreshCache(into: container.mainContext)
                }
            }
        }
    }
}
