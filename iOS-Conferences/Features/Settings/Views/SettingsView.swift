import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(TipJarService.self) private var tipJar
    @Environment(\.requestReview) private var requestReview
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack {
            Form {
                supportSection
                contributeSection
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
            .task {
                await tipJar.load()
            }
        }
    }

    @ViewBuilder
    private var supportSection: some View {
        Section {
            Button {
                Task { await viewModel.tip(using: tipJar) }
            } label: {
                LabeledContent {
                    Text(priceLabel)
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Buy me a coffee", systemImage: "cup.and.saucer.fill")
                }
            }
            .disabled(tipJar.isPurchasing || tipJar.product == nil)

            if tipJar.tipCount > 0 {
                Text(thanksText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Support")
        } footer: {
            Text("A one-time, repeatable tip. No subscriptions.")
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
                requestReview()
            } label: {
                Label("Rate the app", systemImage: "star")
            }
            Button {
                viewModel.isShowingSourceRepo = true
            } label: {
                Label("View source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
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

    private var priceLabel: String {
        tipJar.product?.displayPrice ?? "€1.49"
    }

    private var thanksText: String {
        let count = tipJar.tipCount
        if count == 1 {
            return "You've bought me 1 coffee ☕ — thank you!"
        }
        return "You've bought me \(count) coffees ☕ — thank you!"
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.shared)
        .environment(CalendarService())
        .environment(TipJarService.preview(tipCount: 3))
}
