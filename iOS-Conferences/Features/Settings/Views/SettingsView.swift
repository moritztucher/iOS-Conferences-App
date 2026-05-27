import SwiftUI
import SwiftData
import StoreKit
import MessageUI

struct SettingsView: View {
    @Environment(TipJarService.self) private var tipJar
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @AppStorage("settings.showPastConferences") private var showPastConferences = false
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack {
            Form {
                displaySection
                supportSection
                contributeSection
                tipSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $bindable.isShowingSuggest) {
                SuggestConferenceView()
            }
            .sheet(isPresented: $bindable.isShowingSourceRepo) {
                SafariView(url: RepoConfig.repoWebURL)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $bindable.isShowingMail) {
                MailComposeView(
                    recipient: RepoConfig.developerEmail,
                    subject: "dubdub"
                )
                .ignoresSafeArea()
            }
            .task {
                await tipJar.load()
            }
        }
    }

    @ViewBuilder
    private var tipSection: some View {
        Section {
            Button {
                Task { await viewModel.tip(using: tipJar) }
            } label: {
                HStack {
                    Label("Buy me a coffee · \(priceLabel)", systemImage: "cup.and.saucer.fill")
                        .foregroundStyle(.white)
                    Spacer()
                }
                .contentShape(.rect)
            }
            .listRowBackground(Color.accentColor)
            .disabled(tipJar.isPurchasing || tipJar.product == nil)
        } footer: {
            Text(tipFooterText)
        }
    }

    @ViewBuilder
    private var supportSection: some View {
        Section("Support") {
            Button {
                requestReview()
            } label: {
                Label("Rate the app", systemImage: "star")
            }
            Button {
                contactMe()
            } label: {
                Label("Contact me", systemImage: "envelope")
            }
        }
    }

    @ViewBuilder
    private var contributeSection: some View {
        Section("Contribute") {
            Button {
                viewModel.isShowingSuggest = true
            } label: {
                Label("Suggest a conference", systemImage: "paperplane")
            }
            Button {
                viewModel.isShowingSourceRepo = true
            } label: {
                Label("View source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        }
    }

    @ViewBuilder
    private var displaySection: some View {
        Section("Display") {
            Toggle("Show past conferences", isOn: $showPastConferences)
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: viewModel.appVersion)
            LabeledContent("License", value: "MIT")
        }
    }

    private var priceLabel: String {
        tipJar.product?.displayPrice ?? "€1.49"
    }

    private var tipFooterText: String {
        if tipJar.tipCount > 0 {
            return thanksText
        }
        return "A one-time, repeatable tip. No subscriptions."
    }

    private var thanksText: String {
        let count = tipJar.tipCount
        if count == 1 {
            return "You've bought me 1 coffee ☕ — thank you!"
        }
        return "You've bought me \(count) coffees ☕ — thank you!"
    }

    private func contactMe() {
        if MFMailComposeViewController.canSendMail() {
            viewModel.isShowingMail = true
        } else if let url = URL(string: "mailto:\(RepoConfig.developerEmail)?subject=iOS%20Conferences") {
            openURL(url)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
        .environment(TipJarService.preview(tipCount: 3))
}
