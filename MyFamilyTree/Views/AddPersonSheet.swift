import SwiftUI

struct AddPersonSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var birthDate = ""
    @State private var deathDate = ""
    @State private var relation = 0

    var body: some View {
        NavigationStack {
            Form {
                Section(app.t(.fieldFullName)) {
                    TextField(app.lang == .ru ? "Имя Фамилия" : "First Last", text: $fullName)
                }
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(app.t(.fieldBirth)).font(.caption).foregroundStyle(.secondary)
                            TextField("дд.мм.гггг", text: $birthDate)
                        }
                        VStack(alignment: .leading) {
                            Text(app.t(.fieldDeath)).font(.caption).foregroundStyle(.secondary)
                            TextField(app.lang == .ru ? "необязательно" : "optional", text: $deathDate)
                        }
                    }
                }
                Section(app.t(.fieldRelation)) {
                    Picker(app.t(.fieldRelation), selection: $relation) {
                        Text(app.t(.relChild)).tag(0)
                        Text(app.t(.relSpouse)).tag(1)
                        Text(app.t(.relParent)).tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                Section(app.t(.fieldPhoto)) {
                    Button(app.lang == .ru ? "📷 Выбрать фото" : "📷 Choose photo") {}
                }
            }
            .navigationTitle(app.t(.addTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(app.t(.save)) {
                        app.addPerson()
                        dismiss()
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(app.t(.cancel)) { dismiss() }
                }
            }
        }
    }
}
