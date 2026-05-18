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
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    func tip(using service: TipJarService) async {
        let success = await service.purchase()
        if !success && service.product != nil {
            // user cancelled or transaction failed — stay quiet, no nag
        }
    }
}
