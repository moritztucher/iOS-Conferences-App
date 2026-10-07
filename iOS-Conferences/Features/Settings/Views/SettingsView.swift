import SwiftUI
import SwiftData
import MessageUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @AppStorage("settings.showPastConferences") private var showPastConferences = false
    @AppStorage(LiveAgendaManager.settingKey) private var showsLiveActivity = true
    @Environment(LiveAgendaManager.self) private var liveAgenda
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
            .scrollContentBackground(.hidden)
            .brandBackground()
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
            
            Button {
                requestReview()
            } label: {
                Label("Rate dubdub", systemImage: "star")
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
        Section {
            Toggle("Show past conferences", isOn: $showPastConferences)
            Toggle(isOn: liveActivityBinding) {
                Text("Live Activity at conferences")
                Text("Shows what's on now and next on your Lock Screen while you're at a conference you're attending.")
            }
            .disabled(!liveAgenda.systemAllowsActivities)
            .onChange(of: showsLiveActivity) {
                Task { await liveAgenda.sync() }
            }
            NavigationLink {
                AppearanceView()
            } label: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }
        } header: {
            Text("Display")
        } footer: {
            if !liveAgenda.systemAllowsActivities {
                // The app toggle can't override iOS; point to the switch that can.
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Activities are turned off for dubdub in iOS Settings.")
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                    .font(.footnote.weight(.semibold))
                }
            }
        }
    }

    /// Reads as off while iOS blocks Live Activities, without overwriting the user's choice.
    private var liveActivityBinding: Binding<Bool> {
        Binding(
            get: { showsLiveActivity && liveAgenda.systemAllowsActivities },
            set: { showsLiveActivity = $0 }
        )
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
        .environment(LiveAgendaManager.preview)
}
