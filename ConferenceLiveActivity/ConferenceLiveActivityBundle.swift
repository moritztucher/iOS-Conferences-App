import SwiftUI
import WidgetKit

/// Widget extension entry point. Holds only the conference-day Live Activity (ADR-0009);
/// Home Screen widgets can join this bundle later (docs/iOS26-OPPORTUNITIES.md §1.1).
@main
struct ConferenceLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        ConferenceDayLiveActivity()
    }
}
