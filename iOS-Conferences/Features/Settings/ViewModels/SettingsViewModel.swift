import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var isShowingSuggest = false
    var isShowingSourceRepo = false
    var isShowingMail = false
    var isShowingTwoStrawsAck = false

    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
