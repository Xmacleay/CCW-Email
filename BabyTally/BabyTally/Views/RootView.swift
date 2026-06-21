import SwiftUI
import SwiftData

struct RootView: View {
    @Query(sort: \Child.sortOrder) private var children: [Child]
    @State private var selectedChildID: PersistentIdentifier?

    private var selectedChild: Child? {
        children.first { $0.persistentModelID == selectedChildID } ?? children.first
    }

    var body: some View {
        Group {
            if children.isEmpty {
                ChildEditorView(child: nil)
            } else if let child = selectedChild {
                TabView {
                    HomeView(child: child)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    HistoryView(child: child)
                        .tabItem { Label("History", systemImage: "clock.fill") }
                    StatsView(child: child)
                        .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                    SettingsView(children: children, selectedChildID: $selectedChildID)
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                }
            }
        }
        .onChange(of: children) { _, newChildren in
            if selectedChildID == nil {
                selectedChildID = newChildren.first?.persistentModelID
            }
        }
        .onAppear {
            if selectedChildID == nil {
                selectedChildID = children.first?.persistentModelID
            }
        }
    }
}
