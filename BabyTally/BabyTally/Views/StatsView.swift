import SwiftUI
import Charts

private struct DayStat: Identifiable {
    let day: Date
    let feedCount: Int
    let diaperCount: Int
    let sleepHours: Double
    var id: Date { day }
}

struct StatsView: View {
    let child: Child

    private var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().map { calendar.date(byAdding: .day, value: -$0, to: today)! }
    }

    private var stats: [DayStat] {
        let calendar = Calendar.current
        return last7Days.map { day in
            let feedCount = child.feedEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            let diaperCount = child.diaperEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            let sleepSeconds = child.sleepEntries
                .filter { calendar.isDate($0.startDate, inSameDayAs: day) }
                .reduce(0.0) { $0 + $1.duration }
            return DayStat(day: day, feedCount: feedCount, diaperCount: diaperCount, sleepHours: sleepSeconds / 3600)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    chartSection(title: "Feeds per day") {
                        Chart(stats) { stat in
                            BarMark(x: .value("Day", stat.day, unit: .day), y: .value("Feeds", stat.feedCount))
                                .foregroundStyle(.pink)
                        }
                    }

                    chartSection(title: "Diapers per day") {
                        Chart(stats) { stat in
                            BarMark(x: .value("Day", stat.day, unit: .day), y: .value("Diapers", stat.diaperCount))
                                .foregroundStyle(.brown)
                        }
                    }

                    chartSection(title: "Sleep hours per day") {
                        Chart(stats) { stat in
                            BarMark(x: .value("Day", stat.day, unit: .day), y: .value("Hours", stat.sleepHours))
                                .foregroundStyle(.indigo)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }

    @ViewBuilder
    private func chartSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
        }
    }
}
