import SwiftUI
import MessageUI

struct SuggestConferenceView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SuggestConferenceViewModel()
    @State private var isShowingMail = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, websiteURL, startTime, endTime, timeZone, location, contributor
    }

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack {
            Form {
                Section("Conference") {
                    TextField("Name", text: $bindable.name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                    TextField("Website URL", text: $bindable.websiteURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .websiteURL)
                        .submitLabel(.next)
                }

                Section("When & Where (Optional)") {
                    DatePicker("Start", selection: $bindable.startDate, displayedComponents: .date)
                    DatePicker("End", selection: $bindable.endDate, in: viewModel.startDate..., displayedComponents: .date)
                    TextField("Start time (optional, e.g. 19:00)", text: $bindable.startTime)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($focusedField, equals: .startTime)
                        .submitLabel(.next)
                    TextField("End time (optional)", text: $bindable.endTime)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($focusedField, equals: .endTime)
                        .submitLabel(.next)
                    TextField("Time zone (online events, e.g. Europe/Berlin)", text: $bindable.timeZone)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .timeZone)
                        .submitLabel(.next)
                    TextField("Location (city, country) or 'Online'", text: $bindable.location)
                        .focused($focusedField, equals: .location)
                        .submitLabel(.next)
                }

                Section("Description (Optional)") {
                    TextField("One-line summary", text: $bindable.summary, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    TextField("GitHub handle (optional)", text: $bindable.contributor)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .contributor)
                        .submitLabel(.done)
                } header: {
                    Text("Credit")
                } footer: {
                    Text("Used to credit your contribution if it's added to the list.")
                        .font(.footnote)
                }
            }
            .onSubmit {
                switch focusedField {
                case .name: focusedField = .websiteURL
                case .websiteURL: focusedField = .startTime
                case .startTime: focusedField = .endTime
                case .endTime: focusedField = .timeZone
                case .timeZone: focusedField = .location
                case .location: focusedField = .contributor
                case .contributor, .none: focusedField = nil
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
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 26)
                    }
                    // Same action-bar language as the detail screen's pinned bar (ADR-0007)
                    // — this was the app's only `.borderedProminent`.
                    .buttonStyle(.glassProminent)
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
                    recipient: RepoConfig.developerEmail,
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
