import SwiftUI

/// Month-primary list of conference cards (year folded into the header), each month split
/// into kind groups in display order. Type sub-dividers appear only in months that mix
/// kinds, so dense months (WWDC week) get organised while quiet months stay clean. Shared
/// by the Conferences/Favourites tabs and the Search tab; the host supplies the favourite
/// toggle and owns the `NavigationStack` + `navigationDestination`.
struct ConferenceSectionList: View {
    let sections: [ConferenceMonthSection]
    let favouriteIDs: Set<String>
    /// Shared with the host's `navigationDestination` so tapping a card zooms into the
    /// detail hero (`.navigationTransition(.zoom(sourceID:in:))`).
    let namespace: Namespace.ID
    let onToggleFavourite: (Conference) -> Void

    /// Bumped by the swipe action so the haptic fires only on a swipe here — not when
    /// `favouriteIDs` changes from elsewhere (e.g. the detail screen, which has its own).
    @State private var favouriteTrigger = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        List {
            ForEach(sections) { month in
                Section {
                    ForEach(month.groups) { group in
                        if month.showsTypeHeaders {
                            TypeSubheader(title: group.title, count: group.conferences.count)
                        }
                        ForEach(group.conferences) { conference in
                            card(for: conference)
                        }
                    }
                } header: {
                    MonthSectionHeader(title: month.title, isPast: month.isPast)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .brandBackground()
        .sensoryFeedback(.impact(weight: .light), trigger: favouriteTrigger)
    }

    private func card(for conference: Conference) -> some View {
        ConferenceCard(
            conference: conference,
            isFavourite: favouriteIDs.contains(conference.id)
        )
        // Full-card tap target without the List's NavigationLink chevron, which would break
        // the full-bleed card edge. Glued directly to the card (before the scroll transition)
        // so it scales *with* the card and the disclosure indicator stays hidden behind it.
        .background {
            NavigationLink(value: Route.conferenceDetail(conferenceID: conference.id)) {
                Color.clear
            }
        }
        .matchedTransitionSource(id: conference.id, in: namespace)
        // Subtle "alive" entrance/exit as cards cross the viewport edges — fade + slight
        // shrink. Reduce-motion collapses it to the identity (no movement).
        .scrollTransition { content, phase in
            content
                .opacity(reduceMotion || phase.isIdentity ? 1 : 0.5)
                .scaleEffect(reduceMotion || phase.isIdentity ? 1 : 0.94)
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            favouriteSwipeAction(for: conference)
        }
    }

    @ViewBuilder
    private func favouriteSwipeAction(for conference: Conference) -> some View {
        let isFavourite = favouriteIDs.contains(conference.id)
        Button {
            onToggleFavourite(conference)
            favouriteTrigger += 1
        } label: {
            Label(
                isFavourite ? "Unfavourite" : "Favourite",
                systemImage: isFavourite ? "heart.slash.fill" : "heart.fill"
            )
        }
        .tint(isFavourite ? .gray : .pink)
    }
}

/// Primary month divider — bold, tracked, aligned to the card edge, with the year folded
/// in (e.g. "JUNE 2026"). The pinned `.plain` section header: the serif sits on a glass
/// capsule so it stays legible riding over card artwork mid-scroll (the same system the
/// toolbar buttons use), instead of colliding with whatever ticket happens to be under it.
/// Past months recede to match the aliveness treatment of the tickets beneath them.
private struct MonthSectionHeader: View {
    let title: String
    let isPast: Bool

    var body: some View {
        Text(title)
            .font(Theme.serif(.title3, weight: .bold))
            .tracking(0.5)
            .textCase(nil)
            .foregroundStyle(.primary)
            .opacity(isPast ? 0.55 : 1)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .glassEffect()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets())
    }
}

/// Secondary kind sub-divider shown inside a month that mixes kinds — lighter than the
/// month header, with a trailing count so dense kinds (e.g. Watch Parties in WWDC week)
/// announce themselves. A plain row, not a section header.
private struct TypeSubheader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .eyebrow(.subheadline, weight: .semibold)
            Spacer(minLength: 8)
            Text("\(count)")
                .font(.footnote.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
        .padding(.bottom, 2)
        .padding(.horizontal, 16)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
