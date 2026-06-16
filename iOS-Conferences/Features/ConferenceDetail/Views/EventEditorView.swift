import SwiftUI
import EventKit
import EventKitUI

struct EventEditorView: UIViewControllerRepresentable {
    let event: EKEvent
    let eventStore: EKEventStore
    /// Called when the user actually saves the event (not on cancel/delete) — used to award
    /// the "added to calendar" collectible.
    var onSaved: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: dismiss, onSaved: onSaved)
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onDismiss: DismissAction
        let onSaved: () -> Void

        init(onDismiss: DismissAction, onSaved: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onSaved = onSaved
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            if action == .saved { onSaved() }
            onDismiss()
        }
    }
}
