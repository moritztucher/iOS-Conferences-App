import Foundation
import SwiftData

/// A one-shot action that earns a collectible icon the first time it happens.
enum AchievementEvent: Equatable {
    case addedToCalendar
    case visitedWebsite
    case suggestedConference
}

/// Tracks which collectible app icons the user has unlocked and surfaces freshly-earned
/// ones for celebration. The single source of truth for *unlocked* state is the persisted
/// `UnlockedIcon` store; this service caches the IDs for synchronous reads and evaluates
/// the `AppIcon.UnlockRule`s as the user acts.
///
/// Injected app-wide via `.environment` and configured once from the root view's `.task`,
/// where the SwiftData context is available. Unlocks are **permanent**: dropping below a
/// favourite threshold never re-locks a ticket.
@MainActor
@Observable
final class AchievementService {
    /// IDs of unlocked icons, mirroring the persisted rows for synchronous reads.
    private(set) var unlockedIDs: Set<String> = []
    /// Freshly-unlocked icons awaiting their celebration sheet (FIFO). The root view
    /// presents `pendingCelebration` and pops via `dismissCurrentCelebration()`.
    private(set) var celebrationQueue: [AppIcon] = []

    private var context: ModelContext?
    /// While true, unlocks persist silently without queuing a celebration — used during the
    /// launch replay so a date-window ticket (or a threshold an updating user already passed)
    /// quietly appears as collected instead of slamming a sheet over the first screen. Live
    /// favourite-threshold unlocks celebrate immediately; live *event* unlocks are deferred
    /// too (see `unlock`), since their earning action is presenting its own sheet.
    private var isReplaying = false

    /// The next ticket to celebrate, or `nil` when the queue is empty. Drives the root sheet.
    var pendingCelebration: AppIcon? { celebrationQueue.first }

    /// How many of the collection the user has earned (the always-free default counts).
    var collectedCount: Int {
        AppIcon.allCases.filter(isUnlocked).count
    }

    /// Wire up persistence, then replay any state-derived unlocks the user has already
    /// earned — a favourite threshold already met, or a date window now in range — so they
    /// land even if the action happened before this feature existed. Call once on launch.
    func configure(context: ModelContext, now: Date = .now) {
        self.context = context
        let rows = (try? context.fetch(FetchDescriptor<UnlockedIcon>())) ?? []
        unlockedIDs = Set(rows.map(\.iconID))
        // Replayed unlocks are discoveries, not earnings — persist them, but don't celebrate.
        isReplaying = true
        evaluateLaunch(now: now)
        reevaluateFavourites()
        isReplaying = false
    }

    // MARK: - Queries

    func isUnlocked(_ icon: AppIcon) -> Bool {
        if case .always = icon.unlockRule { return true }
        return unlockedIDs.contains(icon.id)
    }

    /// Numeric progress toward a *count-based* rule (e.g. 3/5 favourites), or `nil` for
    /// already-unlocked, one-shot, date, and always rules.
    func progress(for icon: AppIcon) -> (current: Int, target: Int)? {
        guard case .favourites(let target) = icon.unlockRule, !isUnlocked(icon) else { return nil }
        return (min(favouriteCount, target), target)
    }

    // MARK: - Evaluation entry points

    /// Record a one-shot action, unlocking any ticket gated on it (no-op if already earned).
    func record(_ event: AchievementEvent) {
        for icon in AppIcon.allCases where icon.unlockRule == .event(event) {
            unlock(icon)
        }
    }

    /// Re-check favourite-count tickets against the current favourite total. Call after a
    /// favourite is added; idempotent, so calling it after a removal is harmless.
    func reevaluateFavourites() {
        let count = favouriteCount
        for icon in AppIcon.allCases {
            if case .favourites(let target) = icon.unlockRule, count >= target {
                unlock(icon)
            }
        }
    }

    /// Unlock any seasonal ticket whose date window contains `now`.
    func evaluateLaunch(now: Date) {
        for icon in AppIcon.allCases {
            if case .dateWindow(let window) = icon.unlockRule, window.contains(now) {
                unlock(icon)
            }
        }
    }

    /// Present any *deferred* celebrations — seasonal tickets earned silently at launch that
    /// have been waiting for a calm moment. Called when the user reaches the Appearance
    /// screen (the collection's home), so the celebration lands there instead of over the
    /// first screen on cold launch. Each is marked shown so it fires exactly once.
    func flushDeferredCelebrations() {
        guard let context else { return }
        let rows = (try? context.fetch(FetchDescriptor<UnlockedIcon>())) ?? []
        for row in rows where !row.celebrationShown {
            if let icon = AppIcon.allCases.first(where: { $0.id == row.iconID }) {
                celebrationQueue.append(icon)
            }
            row.celebrationShown = true
        }
        try? context.save()
    }

    /// Pop the celebrated ticket once its sheet is dismissed.
    func dismissCurrentCelebration() {
        guard !celebrationQueue.isEmpty else { return }
        celebrationQueue.removeFirst()
    }

    // MARK: - Internals

    private var favouriteCount: Int {
        guard let context else { return 0 }
        return (try? context.fetchCount(FetchDescriptor<FavouriteConference>())) ?? 0
    }

    private func unlock(_ icon: AppIcon) {
        guard !isUnlocked(icon), let context else { return }
        unlockedIDs.insert(icon.id)
        // Whether this ticket celebrates *now* or waits for a calm moment — the Appearance
        // screen, via `flushDeferredCelebrations`. Deferred when:
        //  • it's a seasonal ticket discovered during the launch replay — don't slam a sheet
        //    over the first screen on cold launch; or
        //  • it's earned live by a one-shot *event* — the earning action (opening the website,
        //    calendar, or suggestion sheet) is presenting its own sheet on this same runloop
        //    turn, so queuing the celebration simultaneously wedged SwiftUI's presentation and
        //    left the action's sheet unopenable until relaunch (issue #38).
        // A favourite-threshold ticket earned live still celebrates immediately: toggling a
        // favourite opens no sheet, so nothing contends for presentation.
        let deferred: Bool
        if isReplaying {
            deferred = icon.isSeasonal
        } else if case .event = icon.unlockRule {
            deferred = true
        } else {
            deferred = false
        }
        context.insert(UnlockedIcon(iconID: icon.id, celebrationShown: !deferred))
        try? context.save()
        if !deferred && !isReplaying { celebrationQueue.append(icon) }
    }
}
