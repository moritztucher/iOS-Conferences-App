import SwiftUI

struct AppearanceView: View {
    @AppStorage("settings.colorScheme") private var colorSchemeRaw = AppColorScheme.system.rawValue
    @State private var viewModel = AppIconViewModel()

    var body: some View {
        List {
            colorSchemeSection
            appIconSection
        }
        .navigationTitle("Appearance")
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
    private var colorSchemeSection: some View {
        Section {
            Picker("Color Scheme", selection: $colorSchemeRaw) {
                ForEach(AppColorScheme.allCases) { scheme in
                    Text(scheme.title).tag(scheme.rawValue)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Color Scheme")
        } footer: {
            Text("Choose how the app looks. System follows your device setting.")
        }
    }

    @ViewBuilder
    private var appIconSection: some View {
        Section {
            ForEach(AppIcon.allCases) { icon in
                Button {
                    Task { await viewModel.select(icon) }
                } label: {
                    row(for: icon)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("App Icon")
        } footer: {
            Text("Collectible icons marking milestones in Apple history. iOS shows a brief alert when the icon changes.")
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
    NavigationStack { AppearanceView() }
}
