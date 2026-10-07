import Foundation

enum Route: Hashable {
    case conferenceDetail(conferenceID: String)
    case conferenceSchedule(conferenceID: String)
}
