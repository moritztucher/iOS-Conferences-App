import SwiftUI

struct AppIconView: View {
    @State private var viewModel = AppIconViewModel()

    var body: some View {
        List {
            Section {
                ForEach(AppIcon.allCases) { icon in
                    Button {
                        Task { await viewModel.select(icon) }
                    } label: {
                        row(for: icon)
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text("Collectible icons marking milestones in Apple history. iOS shows a brief alert when the icon changes.")
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't change the icon", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func row(for icon: AppIcon) -> some View {
        HStack(spacing: 12) {
            Image(icon.previewAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(.separator, lineWidth: 0.5)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(icon.title)
                Text(icon.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if viewModel.selected == icon {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }
        }
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack { AppIconView() }
}
