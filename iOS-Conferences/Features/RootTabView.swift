import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AchievementService.self) private var achievements
    @Environment(LiveAgendaManager.self) private var liveAgenda
    @Environment(\.scenePhase) private var scenePhase

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
        // Persistence isn't available until the view tree is under the model container, so
        // the service is wired here rather than at `@main`. Replays any already-earned
        // unlocks (date window / favourite threshold) on launch.
        .task { achievements.configure(context: modelContext) }
        // Foregrounding is the most reliable moment to correct the Live Activity (ADR-0009).
        .task(id: scenePhase) {
            if scenePhase == .active { await liveAgenda.sync() }
        }
        .task { await liveAgenda.observeAuthorization() }
        // App-level so a freshly-earned ticket celebrates wherever the user is.
        .sheet(item: celebrationBinding) { icon in
            IconUnlockCelebrationView(icon: icon)
        }
    }

    /// Presents the next queued unlock; dismissing pops it so the next (if any) follows.
    private var celebrationBinding: Binding<AppIcon?> {
        Binding(
            get: { achievements.pendingCelebration },
            set: { if $0 == nil { achievements.dismissCurrentCelebration() } }
        )
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
        .environment(AchievementService())
        .environment(LiveAgendaManager.preview)
}
