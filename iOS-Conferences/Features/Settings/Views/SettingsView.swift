import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
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
                acknowledgementsSection
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
                    subject: "Support Request: Dubdub - Conferences & Events"
                )
                .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var supportSection: some View {
        Section("Support") {
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
            NavigationLink {
                AppearanceView()
            } label: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }
        }
    }

    @ViewBuilder
    private var acknowledgementsSection: some View {
        Section {
            NavigationLink {
                AcknowledgementsView()
            } label: {
                Label("Acknowledgements", systemImage: "heart")
            }
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: viewModel.appVersion)
            LabeledContent("License", value: "MIT")
        }
    }

    private func contactMe() {
        if MFMailComposeViewController.canSendMail() {
            viewModel.isShowingMail = true
        } else if let url = URL(
            string: "mailto:\(RepoConfig.developerEmail)?subject=Support%20Request:%20Dubdub%20-%20Conferences%20%26%20Events"
        ) {
            openURL(url)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
}
