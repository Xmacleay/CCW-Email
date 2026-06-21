import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var child: Child
    @Environment(\.modelContext) private var context

    @State private var showingFeedSheet = false
    @State private var showingDiaperSheet = false
    @State private var showingGrowthSheet = false

    private var lastFeed: FeedEntry? {
        child.feedEntries.max { $0.date < $1.date }
    }

    private var lastDiaper: DiaperEntry? {
        child.diaperEntries.max { $0.date < $1.date }
    }

    private var ongoingSleep: SleepEntry? {
        child.sleepEntries.first { $0.isOngoing }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard

                    if let sleep = ongoingSleep {
                        sleepingBanner(sleep)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        QuickLogButton(title: "Feed", systemImage: "drop.fill", tint: .pink) {
                            showingFeedSheet = true
                        }
                        QuickLogButton(title: "Diaper", systemImage: "tray.fill", tint: .brown) {
                            showingDiaperSheet = true
                        }
                        QuickLogButton(
                            title: ongoingSleep == nil ? "Start Sleep" : "End Sleep",
                            systemImage: ongoingSleep == nil ? "moon.fill" : "sun.max.fill",
                            tint: .indigo
                        ) {
                            toggleSleep()
                        }
                        QuickLogButton(title: "Growth", systemImage: "ruler.fill", tint: .green) {
                            showingGrowthSheet = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(child.name)
            .sheet(isPresented: $showingFeedSheet) {
                FeedLogSheet(child: child)
            }
            .sheet(isPresented: $showingDiaperSheet) {
                DiaperLogSheet(child: child)
            }
            .sheet(isPresented: $showingGrowthSheet) {
                GrowthLogSheet(child: child)
            }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 12) {
            statusRow(icon: "drop.fill", label: "Last feed", date: lastFeed?.date, tint: .pink)
            Divider()
            statusRow(icon: "tray.fill", label: "Last diaper", date: lastDiaper?.date, tint: .brown)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statusRow(icon: String, label: String, date: Date?, tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(date.map { TimeFormatting.relative($0) } ?? "No entries yet")
                .fontWeight(.semibold)
        }
    }

    private func sleepingBanner(_ sleep: SleepEntry) -> some View {
        HStack {
            Image(systemName: "moon.zzz.fill")
            Text("Asleep since \(TimeFormatting.shortTime(sleep.startDate))")
            Spacer()
            Text(TimeFormatting.duration(sleep.duration))
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.indigo.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }

    private func toggleSleep() {
        if let sleep = ongoingSleep {
            sleep.endDate = .now
        } else {
            context.insert(SleepEntry(child: child))
        }
        try? context.save()
    }
}

private struct QuickLogButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .foregroundStyle(.white)
            .background(tint.gradient, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
