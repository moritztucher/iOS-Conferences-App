import SwiftUI

/// Calendar-app-style time-zone chooser: a searchable list of the IANA zones, pushed from
/// the suggest form's "Time Zone" row. Rows show the city with the identifier + current
/// GMT offset as the secondary line; picking one pops back.
struct TimeZonePickerView: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var zoneIDs: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        return all.filter {
            Self.cityName(for: $0).localizedCaseInsensitiveContains(trimmed)
                || $0.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        List(zoneIDs, id: \.self) { id in
            Button {
                selection = id
                dismiss()
            } label: {
                row(for: id)
            }
            .buttonStyle(.plain)
        }
        .searchable(text: $query, prompt: "Search for a city")
        .navigationTitle("Time Zone")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(for id: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Self.cityName(for: id))
                Text("\(id) · \(Self.offsetLabel(for: id))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if id == selection {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(id == selection ? [.isButton, .isSelected] : .isButton)
    }

    /// "America/Argentina/Buenos_Aires" → "Buenos Aires"
    static func cityName(for id: String) -> String {
        (id.split(separator: "/").last.map(String.init) ?? id)
            .replacingOccurrences(of: "_", with: " ")
    }

    /// e.g. "GMT+2" — the zone's *current* offset, like the Calendar app shows.
    static func offsetLabel(for id: String) -> String {
        TimeZone(identifier: id)?.localizedName(for: .shortGeneric, locale: .current)
            ?? TimeZone(identifier: id)?.abbreviation()
            ?? ""
    }
}

#Preview {
    @Previewable @State var selection = TimeZone.current.identifier
    NavigationStack {
        TimeZonePickerView(selection: $selection)
    }
}
