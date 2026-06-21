import Foundation
import SwiftData

enum DiaperType: String, Codable, CaseIterable, Identifiable {
    case wet, dirty, both

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wet: return "Wet"
        case .dirty: return "Dirty"
        case .both: return "Both"
        }
    }
}

@Model
final class DiaperEntry {
    var date: Date
    var type: DiaperType
    var note: String?
    var child: Child?

    init(date: Date = .now, type: DiaperType, note: String? = nil, child: Child? = nil) {
        self.date = date
        self.type = type
        self.note = note
        self.child = child
    }
}
