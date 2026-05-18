import Foundation
import SwiftData

@Model
final class Conference {
    #Unique<Conference>([\.id])

    var id: String
    var name: String
    var startDate: Date
    var endDate: Date
    var locationName: String
    var mapQuery: String?
    var summary: String
    var websiteURLString: String
    var tags: [String]

    init(
        id: String,
        name: String,
        startDate: Date,
        endDate: Date,
        locationName: String,
        mapQuery: String?,
        summary: String,
        websiteURLString: String,
        tags: [String]
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locationName = locationName
        self.mapQuery = mapQuery
        self.summary = summary
        self.websiteURLString = websiteURLString
        self.tags = tags
    }
}

extension Conference {
    var websiteURL: URL? { URL(string: websiteURLString) }
    var isPast: Bool { endDate < .now }
    var isOnline: Bool { mapQuery == nil || locationName.localizedCaseInsensitiveContains("online") }
}
