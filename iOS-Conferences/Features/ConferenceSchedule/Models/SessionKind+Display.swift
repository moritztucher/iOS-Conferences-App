import ConferenceKit

extension SessionKind {
    /// SF Symbol for the session's kind in schedule rows.
    var symbolName: String {
        switch self {
        case .keynote: "star.fill"
        case .talk: "mic.fill"
        case .workshop: "hammer.fill"
        case .break: "cup.and.saucer.fill"
        case .social: "party.popper.fill"
        }
    }

    /// Spoken kind for VoiceOver, e.g. "Keynote".
    var label: String {
        switch self {
        case .keynote: "Keynote"
        case .talk: "Talk"
        case .workshop: "Workshop"
        case .break: "Break"
        case .social: "Social"
        }
    }
}
