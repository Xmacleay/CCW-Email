import SwiftUI

private enum TimelineItem: Identifiable {
    case feed(FeedEntry)
    case diaper(DiaperEntry)
    case sleep(SleepEntry)
    case growth(GrowthEntry)

    var id: String {
        switch self {
        case .feed(let entry): return "feed-\(entry.persistentModelID)"
        case .diaper(let entry): return "diaper-\(entry.persistentModelID)"
        case .sleep(let entry): return "sleep-\(entry.persistentModelID)"
        case .growth(let entry): return "growth-\(entry.persistentModelID)"
        }
    }

    var date: Date {
        switch self {
        case .feed(let entry): return entry.date
        case .diaper(let entry): return entry.date
        case .sleep(let entry): return entry.startDate
        case .growth(let entry): return entry.date
        }
    }
}

struct HistoryView: View {
    let child: Child
    @Environment(\.modelContext) private var context

    private var groupedItems: [(day: Date, items: [TimelineItem])] {
        let items: [TimelineItem] =
            child.feedEntries.map(TimelineItem.feed)
            + child.diaperEntries.map(TimelineItem.diaper)
            + child.sleepEntries.map(TimelineItem.sleep)
            + child.growthEntries.map(TimelineItem.growth)

        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { calendar.startOfDay(for: $0.date) }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (day: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedItems, id: \.day) { group in
                    Section(TimeFormatting.dayLabel(group.day)) {
                        ForEach(group.items) { item in
                            row(for: item)
                        }
                    }
                }
            }
            .overlay {
                if groupedItems.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "clock", description: Text("Log a feed, diaper, or sleep from the Home tab."))
                }
            }
            .navigationTitle("History")
        }
    }

    @ViewBuilder
    private func row(for item: TimelineItem) -> some View {
        switch item {
        case .feed(let entry):
            HStack {
                Image(systemName: entry.type.systemImage).foregroundStyle(.pink).frame(width: 24)
                Text(entry.type.label)
                Spacer()
                if let amount = entry.amountML {
                    Text("\(Int(amount)) ml").foregroundStyle(.secondary)
                }
                Text(TimeFormatting.shortTime(entry.date)).foregroundStyle(.secondary)
            }
            .swipeActions { deleteButton { context.delete(entry) } }
        case .diaper(let entry):
            HStack {
                Image(systemName: "tray.fill").foregroundStyle(.brown).frame(width: 24)
                Text(entry.type.label)
                Spacer()
                Text(TimeFormatting.shortTime(entry.date)).foregroundStyle(.secondary)
            }
            .swipeActions { deleteButton { context.delete(entry) } }
        case .sleep(let entry):
            HStack {
                Image(systemName: "moon.fill").foregroundStyle(.indigo).frame(width: 24)
                Text(entry.isOngoing ? "Sleeping…" : TimeFormatting.duration(entry.duration))
                Spacer()
                Text(TimeFormatting.shortTime(entry.startDate)).foregroundStyle(.secondary)
            }
            .swipeActions { deleteButton { context.delete(entry) } }
        case .growth(let entry):
            HStack {
                Image(systemName: "ruler.fill").foregroundStyle(.green).frame(width: 24)
                Text(growthSummary(entry))
                Spacer()
                Text(TimeFormatting.shortTime(entry.date)).foregroundStyle(.secondary)
            }
            .swipeActions { deleteButton { context.delete(entry) } }
        }
    }

    private func growthSummary(_ entry: GrowthEntry) -> String {
        var parts: [String] = []
        if let w = entry.weightKg { parts.append(String(format: "%.1fkg", w)) }
        if let h = entry.heightCm { parts.append(String(format: "%.1fcm", h)) }
        return parts.isEmpty ? "Growth entry" : parts.joined(separator: " · ")
    }

    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button(role: .destructive) {
            action()
            try? context.save()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
