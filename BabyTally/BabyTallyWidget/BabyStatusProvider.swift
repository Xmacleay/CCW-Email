import WidgetKit
import SwiftData
import Foundation

struct BabyStatusEntry: TimelineEntry {
    let date: Date
    let childName: String
    let lastFeed: Date?
    let lastDiaper: Date?
}

struct BabyStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> BabyStatusEntry {
        BabyStatusEntry(date: .now, childName: "Baby", lastFeed: .now.addingTimeInterval(-1800), lastDiaper: .now.addingTimeInterval(-3600))
    }

    func getSnapshot(in context: Context, completion: @escaping (BabyStatusEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BabyStatusEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    /// Fetches everything in-memory rather than via cross-relationship
    /// predicates — entry counts for a single child are small (a few
    /// thousand at most), so this stays fast and avoids #Predicate
    /// limitations with optional relationship key paths.
    private func loadEntry() -> BabyStatusEntry {
        let context = ModelContext(DataController.shared)

        let children = (try? context.fetch(FetchDescriptor<Child>(sortBy: [SortDescriptor(\.sortOrder)]))) ?? []
        guard let child = children.first else {
            return BabyStatusEntry(date: .now, childName: "BabyTally", lastFeed: nil, lastDiaper: nil)
        }

        let childID = child.persistentModelID
        let allFeeds = (try? context.fetch(FetchDescriptor<FeedEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
        let allDiapers = (try? context.fetch(FetchDescriptor<DiaperEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []

        let lastFeed = allFeeds.first { $0.child?.persistentModelID == childID }?.date
        let lastDiaper = allDiapers.first { $0.child?.persistentModelID == childID }?.date

        return BabyStatusEntry(date: .now, childName: child.name, lastFeed: lastFeed, lastDiaper: lastDiaper)
    }
}
