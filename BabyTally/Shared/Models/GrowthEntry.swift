import Foundation
import SwiftData

@Model
final class GrowthEntry {
    var date: Date
    var weightKg: Double?
    var heightCm: Double?
    var headCircumferenceCm: Double?
    var note: String?
    var child: Child?

    init(
        date: Date = .now,
        weightKg: Double? = nil,
        heightCm: Double? = nil,
        headCircumferenceCm: Double? = nil,
        note: String? = nil,
        child: Child? = nil
    ) {
        self.date = date
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.headCircumferenceCm = headCircumferenceCm
        self.note = note
        self.child = child
    }
}
