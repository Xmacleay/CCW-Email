import SwiftUI

struct DiaperLogSheet: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var type: DiaperType = .wet
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(DiaperType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("When") {
                    DatePicker("Time", selection: $date)
                }

                Section("Note") {
                    TextField("Optional", text: $note)
                }
            }
            .navigationTitle("Log Diaper")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let entry = DiaperEntry(date: date, type: type, note: note.isEmpty ? nil : note, child: child)
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
