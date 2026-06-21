import Foundation

/// Builds a single CSV a parent can hand to a pediatrician. Pure, file-free —
/// callers decide how to share/save the resulting string.
enum CSVExporter {
    static func export(
        feeds: [FeedEntry],
        diapers: [DiaperEntry],
        sleeps: [SleepEntry],
        growth: [GrowthEntry]
    ) -> String {
        var lines = ["Type,Date,Detail,Note"]
        let formatter = ISO8601DateFormatter()

        for entry in feeds.sorted(by: { $0.date < $1.date }) {
            let detail: String
            if let amount = entry.amountML {
                detail = "\(entry.type.label) \(Int(amount))ml"
            } else {
                detail = entry.type.label
            }
            lines.append(csvRow(["Feed", formatter.string(from: entry.date), detail, entry.note ?? ""]))
        }

        for entry in diapers.sorted(by: { $0.date < $1.date }) {
            lines.append(csvRow(["Diaper", formatter.string(from: entry.date), entry.type.label, entry.note ?? ""]))
        }

        for entry in sleeps.sorted(by: { $0.startDate < $1.startDate }) {
            let detail = TimeFormatting.duration(entry.duration)
            lines.append(csvRow(["Sleep", formatter.string(from: entry.startDate), detail, entry.note ?? ""]))
        }

        for entry in growth.sorted(by: { $0.date < $1.date }) {
            var parts: [String] = []
            if let w = entry.weightKg { parts.append("\(w)kg") }
            if let h = entry.heightCm { parts.append("\(h)cm") }
            if let hc = entry.headCircumferenceCm { parts.append("head \(hc)cm") }
            lines.append(csvRow(["Growth", formatter.string(from: entry.date), parts.joined(separator: " / "), entry.note ?? ""]))
        }

        return lines.joined(separator: "\n")
    }

    private static func csvRow(_ fields: [String]) -> String {
        fields.map { field -> String in
            if field.contains(",") || field.contains("\"") || field.contains("\n") {
                return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
            }
            return field
        }.joined(separator: ",")
    }
}
