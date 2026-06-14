import SwiftUI
import MessageUI

struct SuggestConferenceView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SuggestConferenceViewModel()
    @State private var isShowingMail = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, websiteURL, location, contributor
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

                // Calendar-app-style entry: an All-day toggle whose off state reveals the
                // time components on the date pickers and a pushed Time Zone chooser.
                Section("When") {
                    Toggle("All-day", isOn: $bindable.isAllDay.animation())
                    DatePicker(
                        "Starts",
                        selection: $bindable.startDate,
                        displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    DatePicker(
                        "Ends",
                        selection: $bindable.endDate,
                        in: viewModel.startDate...,
                        displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    if !viewModel.isAllDay {
                        NavigationLink {
                            TimeZonePickerView(selection: $bindable.timeZoneID)
                        } label: {
                            LabeledContent("Time Zone", value: TimeZonePickerView.cityName(for: viewModel.timeZoneID))
                        }
                    }
                }

                Section("Where") {
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
                case .websiteURL: focusedField = .location
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
