import Foundation

/// The app's primary icon plus the collectible alternate icons — a quiet easter egg
/// marking milestones in Apple history. Each alternate maps to an alternate app-icon
/// set in the asset catalog; a `nil` `alternateName` means the primary icon.
enum AppIcon: String, CaseIterable, Identifiable {
    case `default`
    case appleFounding
    case macintosh
    case iPod
    case iPhone
    case visionPro
    case wwdc26

    var id: String { rawValue }

    /// Asset-catalog alternate-icon name, or `nil` for the primary icon.
    var alternateName: String? {
        switch self {
        case .default: nil
        case .appleFounding: "AppIcon1976"
        case .macintosh: "AppIcon1984"
        case .iPod: "AppIcon2001"
        case .iPhone: "AppIcon2007"
        case .visionPro: "AppIcon2023"
        case .wwdc26: "AppIcon2026"
        }
    }

    /// Image-set used to preview the icon in the picker.
    var previewAsset: String {
        switch self {
        case .default: "IconPreview-default"
        case .appleFounding: "IconPreview-1976"
        case .macintosh: "IconPreview-1984"
        case .iPod: "IconPreview-2001"
        case .iPhone: "IconPreview-2007"
        case .visionPro: "IconPreview-2023"
        case .wwdc26: "IconPreview-2026"
        }
    }

    var title: String {
        switch self {
        case .default: "Tickets"
        case .appleFounding: "Apple Computer Co."
        case .macintosh: "Macintosh"
        case .iPod: "iPod"
        case .iPhone: "iPhone"
        case .visionPro: "Vision Pro"
        case .wwdc26: "WWDC26"
        }
    }

    var subtitle: String {
        switch self {
        case .default: "18 May 2026 · First commit"
        case .appleFounding: "1 Apr 1976 · Los Altos"
        case .macintosh: "24 Jan 1984 · Flint Center"
        case .iPod: "23 Oct 2001 · Apple Campus"
        case .iPhone: "9 Jan 2007 · Moscone Center"
        case .visionPro: "5 Jun 2023 · Apple Park"
        case .wwdc26: "8 Jun 2026 · Apple Park"
        }
    }
}
