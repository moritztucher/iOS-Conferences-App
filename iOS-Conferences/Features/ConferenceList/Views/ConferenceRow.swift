import SwiftUI

struct ConferenceRow: View {
    let conference: Conference
    let isFavourite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(conference.name)
                    .font(.body)
                    .lineLimit(2)
                Spacer(minLength: 8)
                if isFavourite {
                    Image(systemName: "heart.fill")
                        .imageScale(.small)
                        .foregroundStyle(.tint)
                        .accessibilityLabel("Favourite")
                }
            }
            Text(secondaryLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }

    private var secondaryLine: String {
        let range = ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate)
        return "\(range) · \(conference.locationName)"
    }
}

#Preview {
    List {
        ConferenceRow(conference: .sample, isFavourite: true)
        ConferenceRow(conference: Conference.samples[0], isFavourite: false)
    }
}
