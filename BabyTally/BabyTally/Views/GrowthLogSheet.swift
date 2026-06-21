import SwiftUI

struct GrowthLogSheet: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var weightKg: Double = 3.5
    @State private var heightCm: Double = 50
    @State private var headCircumferenceCm: Double = 35
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Measurements") {
                    Stepper(value: $weightKg, in: 0.5...30, step: 0.1) {
                        Text("Weight: \(weightKg, specifier: "%.1f") kg")
                    }
                    Stepper(value: $heightCm, in: 20...130, step: 0.5) {
                        Text("Height: \(heightCm, specifier: "%.1f") cm")
                    }
                    Stepper(value: $headCircumferenceCm, in: 20...60, step: 0.5) {
                        Text("Head: \(headCircumferenceCm, specifier: "%.1f") cm")
                    }
                }

                Section("When") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Note") {
                    TextField("Optional", text: $note)
                }
            }
            .navigationTitle("Log Growth")
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
        let entry = GrowthEntry(
            date: date,
            weightKg: weightKg,
            heightCm: heightCm,
            headCircumferenceCm: headCircumferenceCm,
            note: note.isEmpty ? nil : note,
            child: child
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
