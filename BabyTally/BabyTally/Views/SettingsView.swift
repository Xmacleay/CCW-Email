import SwiftUI
import SwiftData

struct SettingsView: View {
    let children: [Child]
    @Binding var selectedChildID: PersistentIdentifier?
    @Environment(\.modelContext) private var context

    @State private var showingAddChild = false
    @State private var editingChild: Child?
    @State private var exportText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Children") {
                    ForEach(children) { child in
                        HStack {
                            Button {
                                selectedChildID = child.persistentModelID
                            } label: {
                                HStack {
                                    Text(child.name)
                                    if child.persistentModelID == selectedChildID {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .foregroundStyle(.primary)

                            Spacer()

                            Button {
                                editingChild = child
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .onDelete(perform: deleteChildren)

                    Button {
                        showingAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "plus")
                    }
                }

                if let child = children.first(where: { $0.persistentModelID == selectedChildID }) ?? children.first {
                    Section("Export") {
                        ShareLink(
                            item: csv(for: child),
                            preview: SharePreview("\(child.name) — BabyTally export")
                        ) {
                            Label("Export CSV for pediatrician", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section("About") {
                    Label("Everything stays on this device. No account, no cloud sync, no subscription.", systemImage: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Version 1.0")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddChild) {
                ChildEditorView(child: nil)
            }
            .sheet(item: $editingChild) { child in
                ChildEditorView(child: child)
            }
        }
    }

    private func csv(for child: Child) -> String {
        CSVExporter.export(
            feeds: child.feedEntries,
            diapers: child.diaperEntries,
            sleeps: child.sleepEntries,
            growth: child.growthEntries
        )
    }

    private func deleteChildren(at offsets: IndexSet) {
        for index in offsets {
            context.delete(children[index])
        }
        try? context.save()
    }
}

extension Child: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}
