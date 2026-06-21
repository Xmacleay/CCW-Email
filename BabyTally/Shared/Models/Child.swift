import Foundation
import SwiftData

@Model
final class Child {
    var name: String
    var birthDate: Date
    var colorHex: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \FeedEntry.child)
    var feedEntries: [FeedEntry] = []
    @Relationship(deleteRule: .cascade, inverse: \DiaperEntry.child)
    var diaperEntries: [DiaperEntry] = []
    @Relationship(deleteRule: .cascade, inverse: \SleepEntry.child)
    var sleepEntries: [SleepEntry] = []
    @Relationship(deleteRule: .cascade, inverse: \GrowthEntry.child)
    var growthEntries: [GrowthEntry] = []

    init(name: String, birthDate: Date, colorHex: String = "FF6B6B", sortOrder: Int = 0) {
        self.name = name
        self.birthDate = birthDate
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}
