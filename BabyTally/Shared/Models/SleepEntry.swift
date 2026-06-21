import Foundation
import SwiftData

@Model
final class SleepEntry {
    var startDate: Date
    var endDate: Date?
    var note: String?
    var child: Child?

    init(startDate: Date = .now, endDate: Date? = nil, note: String? = nil, child: Child? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.child = child
    }

    var isOngoing: Bool { endDate == nil }

    var duration: TimeInterval {
        (endDate ?? .now).timeIntervalSince(startDate)
    }
}
