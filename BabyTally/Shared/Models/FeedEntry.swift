import Foundation
import SwiftData

enum FeedType: String, Codable, CaseIterable, Identifiable {
    case breastLeft, breastRight, breastBoth, bottle, solid

    var id: String { rawValue }

    var label: String {
        switch self {
        case .breastLeft: return "Breast (L)"
        case .breastRight: return "Breast (R)"
        case .breastBoth: return "Breast (Both)"
        case .bottle: return "Bottle"
        case .solid: return "Solid"
        }
    }

    var systemImage: String {
        switch self {
        case .breastLeft, .breastRight, .breastBoth: return "drop.fill"
        case .bottle: return "waterbottle.fill"
        case .solid: return "fork.knife"
        }
    }
}

@Model
final class FeedEntry {
    var date: Date
    var type: FeedType
    /// Amount in milliliters, only used for bottle feeds.
    var amountML: Double?
    var durationMinutes: Int?
    var note: String?
    var child: Child?

    init(
        date: Date = .now,
        type: FeedType,
        amountML: Double? = nil,
        durationMinutes: Int? = nil,
        note: String? = nil,
        child: Child? = nil
    ) {
        self.date = date
        self.type = type
        self.amountML = amountML
        self.durationMinutes = durationMinutes
        self.note = note
        self.child = child
    }
}
