import SwiftUI

struct SuggestConferenceView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SuggestConferenceViewModel()

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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Submitting opens GitHub. You'll need to sign in once to post the issue.")
                        Link(
                            "Already discussed? Comment on the running thread →",
                            destination: RepoConfig.suggestionsThreadURL
                        )
                    }
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
                Button(action: submit) {
                    Label("Open as GitHub Issue", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isSubmittable)
                .padding()
            }
        }
    }

    private func submit() {
        guard let url = viewModel.buildURL() else { return }
        openURL(url)
        dismiss()
    }
}

#Preview {
    SuggestConferenceView()
}
