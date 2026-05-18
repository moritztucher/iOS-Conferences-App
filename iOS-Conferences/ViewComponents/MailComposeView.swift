import SwiftUI
import MessageUI

/// Bridge for the system `MFMailComposeViewController` — the in-app mail compose sheet.
/// Falls back behavior is decided by the caller; this view itself only wraps the controller.
struct MailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    @Environment(\.dismiss) private var dismiss

    init(recipient: String, subject: String = "", body: String = "") {
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([recipient])
        if !subject.isEmpty { controller.setSubject(subject) }
        if !body.isEmpty { controller.setMessageBody(body, isHTML: false) }
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: DismissAction

        init(onDismiss: DismissAction) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            onDismiss()
        }
    }
}
