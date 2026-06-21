import SwiftUI

struct FeedLogSheet: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var type: FeedType = .bottle
    @State private var amountML: Double = 60
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(FeedType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if type == .bottle {
                    Section("Amount") {
                        Stepper(value: $amountML, in: 10...500, step: 5) {
                            Text("\(Int(amountML)) ml")
                        }
                    }
                }

                Section("When") {
                    DatePicker("Time", selection: $date)
                }

                Section("Note") {
                    TextField("Optional", text: $note)
                }
            }
            .navigationTitle("Log Feed")
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
        let entry = FeedEntry(
            date: date,
            type: type,
            amountML: type == .bottle ? amountML : nil,
            note: note.isEmpty ? nil : note,
            child: child
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
