import SwiftUI
import SwiftData

@main
struct iOS_ConferencesApp: App {
    @State private var calendarService = CalendarService()
    @State private var achievementService = AchievementService()
    @State private var liveAgenda: LiveAgendaManager
    @AppStorage("settings.colorScheme") private var colorSchemeRaw = AppColorScheme.system.rawValue

    /// Created up front (not via `.modelContainer(for:)`) because the Live Activity's
    /// background refresh needs the store even when no window is on screen.
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for:
                Conference.self, FavouriteConference.self, AttendingConference.self,
                ConferenceSchedule.self, FavouriteTalk.self, UnlockedIcon.self
            )
        } catch {
            fatalError("Couldn't open the local store: \(error)")
        }
        _liveAgenda = State(initialValue: LiveAgendaManager(container: modelContainer))
    }

    private var colorScheme: ColorScheme? {
        AppColorScheme(rawValue: colorSchemeRaw)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(calendarService)
                .environment(achievementService)
                .environment(liveAgenda)
                .tint(Theme.accent)
                .preferredColorScheme(colorScheme)
                .task { await seedConferences() }
        }
        .modelContainer(modelContainer)
        .backgroundTask(.appRefresh(LiveAgendaManager.refreshTaskIdentifier)) { [liveAgenda] in
            await liveAgenda.sync()
        }
    }

    private func seedConferences() async {
        let context = modelContainer.mainContext
        // First-launch instant seed from the bundled list — offline-safe,
        // no network wait before the UI has something to show.
        try? await BundledConferenceService().refreshCache(into: context)
        // Background refresh from the live JSON feed. Silently no-ops if
        // the network is unreachable or the file 404s; the bundled seed
        // remains as the displayed cache.
        try? await ConferenceServiceFactory.make().refreshCache(into: context)
    }
}
