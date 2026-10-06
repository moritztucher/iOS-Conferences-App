import ConferenceKit
import SwiftUI

/// One session in the schedule list: kind symbol, title, speakers, time · room, and, for
/// multi-track agenda kinds, a favourite heart. Breaks and socials render quieter, since
/// they're context rather than choices. Stock `List` row content (ADR-0007: stay stock
/// for list rows).
struct SessionRow: View {
    let session: ScheduleSession
    let roomName: String?
    let timeZone: TimeZone
    let isFavourite: Bool
    let showsFavouriteButton: Bool
    let hasConflict: Bool
    let onToggleFavourite: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isAgendaKind: Bool { session.kind.isAgendaKind }

    private var detailLine: String {
        [ConferenceDateStyle.sessionTimeRange(session.startsAt, session.endsAt, in: timeZone), roomName]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: session.kind.symbolName)
                .foregroundStyle(isAgendaKind ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(isAgendaKind ? .headline : .body)
                    .foregroundStyle(isAgendaKind ? .primary : .secondary)
                if !session.speakers.isEmpty {
                    Text(session.speakers.formatted(.list(type: .and)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(detailLine)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if hasConflict {
                    Label("Clashes with another favourite", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsFavouriteButton {
                Button(action: onToggleFavourite) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.title3)
                        .symbolEffect(.bounce, value: isFavourite)
                        .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
                .accessibilityHidden(true)  // Exposed as the row's accessibility action instead.
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isFavourite ? .isSelected : [])
        .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
            if showsFavouriteButton { onToggleFavourite() }
        }
    }

    private var accessibilityLabel: String {
        var parts = [session.kind.label, session.title]
        if !session.speakers.isEmpty { parts.append(session.speakers.formatted(.list(type: .and))) }
        parts.append(detailLine)
        if isFavourite { parts.append("Favourite") }
        if hasConflict { parts.append("Clashes with another favourite") }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    let start = Date.now
    List {
        SessionRow(
            session: ScheduleSession(
                id: "preview-1", kind: .talk, title: "Swift Concurrency in Practice",
                speakers: ["Jane Doe", "John Appleseed"], roomID: "a",
                startsAt: start, endsAt: start.addingTimeInterval(2_700)
            ),
            roomName: "Hall A", timeZone: .current, isFavourite: true,
            showsFavouriteButton: true, hasConflict: true, onToggleFavourite: {}
        )
        SessionRow(
            session: ScheduleSession(
                id: "preview-2", kind: .break, title: "Coffee",
                startsAt: start, endsAt: start.addingTimeInterval(1_800)
            ),
            roomName: nil, timeZone: .current, isFavourite: false,
            showsFavouriteButton: false, hasConflict: false, onToggleFavourite: {}
        )
    }
}
