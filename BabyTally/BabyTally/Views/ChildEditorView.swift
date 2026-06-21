import SwiftUI
import SwiftData

/// Used both for first-run onboarding (child == nil) and for adding
/// additional children later (twins, multiple kids on one device).
struct ChildEditorView: View {
    let child: Child?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthDate = Date.now

    private var isOnboarding: Bool { child == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Baby's name", text: $name)
                    DatePicker("Birth date", selection: $birthDate, displayedComponents: .date)
                }

                if isOnboarding {
                    Section {
                        Text("BabyTally stores everything on this device only. No account, no cloud, no subscription — ever.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isOnboarding ? "Welcome" : "Edit Child")
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            if let child {
                name = child.name
                birthDate = child.birthDate
            }
        }
    }

    private func save() {
        if let child {
            child.name = name
            child.birthDate = birthDate
        } else {
            context.insert(Child(name: name, birthDate: birthDate, sortOrder: nextSortOrder()))
        }
        try? context.save()
        dismiss()
    }

    private func nextSortOrder() -> Int {
        (try? context.fetchCount(FetchDescriptor<Child>())) ?? 0
    }
}
