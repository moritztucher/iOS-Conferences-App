import ConferenceKit
import SwiftUI

/// Sheet for one session: kind, title, speakers, when and where, the organiser's description,
/// and (multi-track) the favourite heart. The description is credited to the organiser's
/// published schedule; when the feed has a session page, it opens in Safari.
struct SessionDetailView: View {
    let session: ScheduleSession
    let roomName: String?
    let timeZone: TimeZone
    let conferenceName: String
    let isFavourite: Bool
    let canFavourite: Bool
    let onToggleFavourite: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingSessionPage = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    facts
                    if let abstract = session.abstract {
                        Divider()
                        Text(abstract)
                            .font(.body)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    sourceFooter
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $isShowingSessionPage) {
                if let url = session.url {
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(session.kind.label, systemImage: session.kind.symbolName)
                .eyebrow(.footnote)
                .foregroundStyle(.tint)
            Text(session.title)
                .font(.title2.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if !session.speakers.isEmpty {
                Text(session.speakers.formatted(.list(type: .and)))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var facts: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(
                ConferenceDateStyle.sessionTimeRange(session.startsAt, session.endsAt, in: timeZone),
                systemImage: "clock"
            )
            if let roomName {
                Label(roomName, systemImage: "mappin.and.ellipse")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var sourceFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            if session.url != nil {
                Button {
                    isShowingSessionPage = true
                } label: {
                    Label("Official session page", systemImage: "safari")
                }
                .buttonStyle(.glass)
            }
            if session.abstract != nil {
                Text("Description as published in \(conferenceName)'s schedule.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Done") { dismiss() }
        }
        if canFavourite {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onToggleFavourite) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .symbolEffect(.bounce, value: reduceMotion ? false : isFavourite)
                }
                .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
            }
        }
    }
}

#Preview {
    let start = Date.now
    SessionDetailView(
        session: ScheduleSession(
            id: "preview-1", kind: .talk, title: "Swift Concurrency in Practice",
            speakers: ["Jane Doe"], roomID: "a",
            abstract: "A walk through structured concurrency in a production app.\n\nWe cover task groups, actors and the pitfalls that only show up at scale.",
            startsAt: start, endsAt: start.addingTimeInterval(2_700)
        ),
        roomName: "Hall A", timeZone: .current, conferenceName: "SwiftLeeds",
        isFavourite: false, canFavourite: true, onToggleFavourite: {}
    )
}
