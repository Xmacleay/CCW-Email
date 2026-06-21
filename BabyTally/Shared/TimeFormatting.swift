import Foundation

enum TimeFormatting {
    /// "12m ago", "3h 20m ago" — built for one-handed, half-asleep reading.
    static func relative(_ date: Date, from now: Date = .now) -> String {
        let seconds = max(0, now.timeIntervalSince(date))
        let minutes = Int(seconds / 60)
        if minutes < 1 { return "just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours < 24 { return remainder == 0 ? "\(hours)h ago" : "\(hours)h \(remainder)m ago" }
        let days = hours / 24
        return days == 1 ? "1 day ago" : "\(days) days ago"
    }

    static func duration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours == 0 { return "\(remainder)m" }
        return "\(hours)h \(remainder)m"
    }

    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func dayLabel(_ date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).month().day())
    }
}
