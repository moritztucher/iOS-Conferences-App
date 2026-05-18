import SwiftUI

struct ConferenceRow: View {
    let conference: Conference
    let isFavourite: Bool

    var body: some View {
        HStack(spacing: 12) {
            ConferenceLogo(url: conference.logoURL, size: 44)

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
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(Color.secondary.opacity(0.15))
            Image(systemName: "calendar")
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        ConferenceRow(conference: .sample, isFavourite: true)
        ConferenceRow(conference: Conference.samples[0], isFavourite: false)
    }
}
