import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var isShowingSuggest = false
    var isShowingSourceRepo = false
    var isShowingMail = false
    var purchaseErrorMessage: String?

    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    func tip(using service: TipJarService) async {
        let success = await service.purchase()
        if !success && service.product != nil {
            // user cancelled or transaction failed — stay quiet, no nag
        }
    }
}
