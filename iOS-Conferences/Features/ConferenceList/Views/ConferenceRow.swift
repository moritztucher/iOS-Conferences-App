import SwiftUI

struct ConferenceRow: View {
    let conference: Conference
    let isFavourite: Bool

    var body: some View {
        HStack(spacing: 12) {
            ConferenceLogo(conference: conference, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(conference.name)
                        .font(.body)
                        .lineLimit(2)
                    Spacer(minLength: 4)
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
        }
        .padding(.vertical, 2)
    }

    private var secondaryLine: String {
        let range = ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate)
        return "\(range) · \(conference.locationName)"
    }
}

struct ConferenceLogo: View {
    let conference: Conference
    let size: CGFloat

    var body: some View {
        AsyncImage(url: conference.logoURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                ConferencePlaceholder(conference: conference)
            @unknown default:
                ConferencePlaceholder(conference: conference)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .accessibilityHidden(true)
    }
}

#Preview {
    List {
        ConferenceRow(conference: .sample, isFavourite: true)
        ConferenceRow(conference: Conference.bundled[0], isFavourite: false)
    }
}
