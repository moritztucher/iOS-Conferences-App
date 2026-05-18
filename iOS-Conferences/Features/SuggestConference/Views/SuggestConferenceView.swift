import SwiftUI
import MessageUI

struct SuggestConferenceView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SuggestConferenceViewModel()
    @State private var isShowingMail = false

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack {
            Form {
                Section("Conference") {
                    TextField("Name", text: $bindable.name)
                    TextField("Website URL", text: $bindable.websiteURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("When & Where (Optional)") {
                    DatePicker("Start", selection: $bindable.startDate, displayedComponents: .date)
                    DatePicker("End", selection: $bindable.endDate, in: viewModel.startDate..., displayedComponents: .date)
                    TextField("Location (city, country) or 'Online'", text: $bindable.location)
                }

                Section("Description (Optional)") {
                    TextField("One-line summary", text: $bindable.summary, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    TextField("GitHub handle (optional)", text: $bindable.contributor)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Credit")
                } footer: {
                    Text("Used to credit your contribution if it's added to the list.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Suggest a Conference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button(action: submitViaEmail) {
                        Label("Email suggestion", systemImage: "envelope")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.isSubmittable)

                    Button(action: submitViaGitHub) {
                        Text("Submit as a GitHub Issue instead")
                            .font(.footnote)
                    }
                    .disabled(!viewModel.isSubmittable)
                }
                .padding()
            }
            .sheet(isPresented: $isShowingMail) {
                let content = viewModel.buildContent()
                MailComposeView(
                    recipient: RepoConfig.supportEmail,
                    subject: content.title,
                    body: content.body
                )
                .ignoresSafeArea()
            }
        }
    }

    private func submitViaEmail() {
        if MFMailComposeViewController.canSendMail() {
            isShowingMail = true
        } else if let url = viewModel.mailtoFallbackURL() {
            openURL(url)
            dismiss()
        }
    }

    private func submitViaGitHub() {
        if let url = viewModel.githubIssueURL() {
            openURL(url)
            dismiss()
        }
    }
}

#Preview {
    SuggestConferenceView()
}
