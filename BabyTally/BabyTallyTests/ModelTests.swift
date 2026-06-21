import XCTest
import SwiftData
@testable import BabyTally

final class ModelTests: XCTestCase {
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Child.self, FeedEntry.self, DiaperEntry.self, SleepEntry.self, GrowthEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    func testSleepEntryDurationWhileOngoing() {
        let start = Date.now.addingTimeInterval(-600)
        let entry = SleepEntry(startDate: start)
        XCTAssertTrue(entry.isOngoing)
        XCTAssertGreaterThanOrEqual(entry.duration, 590)
    }

    func testSleepEntryDurationOnceEnded() {
        let start = Date.now.addingTimeInterval(-3600)
        let end = Date.now.addingTimeInterval(-1800)
        let entry = SleepEntry(startDate: start, endDate: end)
        XCTAssertFalse(entry.isOngoing)
        XCTAssertEqual(entry.duration, 1800, accuracy: 0.5)
    }

    func testChildCascadeDeletesFeedEntries() throws {
        let context = try makeInMemoryContext()
        let child = Child(name: "Test", birthDate: .now)
        context.insert(child)
        context.insert(FeedEntry(type: .bottle, amountML: 90, child: child))
        try context.save()

        context.delete(child)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<FeedEntry>())
        XCTAssertTrue(remaining.isEmpty)
    }

    func testCSVExportIncludesAllEntryTypes() {
        let child = Child(name: "Test", birthDate: .now)
        let feed = FeedEntry(type: .bottle, amountML: 90, child: child)
        let diaper = DiaperEntry(type: .wet, child: child)
        let sleep = SleepEntry(startDate: .now.addingTimeInterval(-3600), endDate: .now, child: child)
        let growth = GrowthEntry(weightKg: 4.2, child: child)

        let csv = CSVExporter.export(feeds: [feed], diapers: [diaper], sleeps: [sleep], growth: [growth])

        XCTAssertTrue(csv.contains("Feed"))
        XCTAssertTrue(csv.contains("Diaper"))
        XCTAssertTrue(csv.contains("Sleep"))
        XCTAssertTrue(csv.contains("Growth"))
        XCTAssertTrue(csv.contains("90ml"))
    }

    func testCSVEscapesCommasAndQuotes() {
        let child = Child(name: "Test", birthDate: .now)
        let diaper = DiaperEntry(type: .wet, note: "rash, redness \"bad\"", child: child)
        let csv = CSVExporter.export(feeds: [], diapers: [diaper], sleeps: [], growth: [])
        XCTAssertTrue(csv.contains("\"rash, redness \"\"bad\"\"\""))
    }

    func testTimeFormattingRelative() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        XCTAssertEqual(TimeFormatting.relative(now.addingTimeInterval(-30), from: now), "just now")
        XCTAssertEqual(TimeFormatting.relative(now.addingTimeInterval(-600), from: now), "10m ago")
        XCTAssertEqual(TimeFormatting.relative(now.addingTimeInterval(-7200), from: now), "2h ago")
    }
}
