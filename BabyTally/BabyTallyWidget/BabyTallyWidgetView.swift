import SwiftUI
import WidgetKit

struct BabyTallyWidgetView: View {
    let entry: BabyStatusEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        default:
            rectangle
        }
    }

    private var rectangle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.childName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            row(icon: "drop.fill", label: "Feed", date: entry.lastFeed)
            row(icon: "tray.fill", label: "Diaper", date: entry.lastDiaper)
        }
    }

    private var circular: some View {
        VStack(spacing: 2) {
            Image(systemName: "drop.fill")
            Text(entry.lastFeed.map(shortRelative) ?? "—")
                .font(.caption2)
                .minimumScaleFactor(0.7)
        }
    }

    private func row(icon: String, label: String, date: Date?) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(date.map { TimeFormatting.relative($0, from: entry.date) } ?? "No data")
                .fontWeight(.semibold)
        }
        .font(.caption2)
    }

    private func shortRelative(_ date: Date) -> String {
        let minutes = Int(entry.date.timeIntervalSince(date) / 60)
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h"
    }
}
