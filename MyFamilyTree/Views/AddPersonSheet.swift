import SwiftUI

enum PersonFormMode: Identifiable {
    case add
    case edit(Person)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let p): return "edit-\(p.id)"
        }
    }
}

struct AddPersonSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    let mode: PersonFormMode

    @State private var name: String = ""
    @State private var years: String = ""
    @State private var relationKind: RelationKind = .child
    @State private var ancestorSide: AncestorSide = .root
    @State private var sex: Sex = .male
    @State private var isEx: Bool = false
    @State private var phone: String = ""
    @State private var whatsapp: String = ""
    @State private var telegram: String = ""
    @State private var instagram: String = ""

    private var isRussian: Bool { app.lang == .ru }
    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    enum RelationKind: CaseIterable, Hashable {
        case parent, spouse, child
        func label(_ ru: Bool) -> String {
            switch self {
            case .parent: return ru ? "Родитель" : "Parent"
            case .spouse: return ru ? "Супруг(а)" : "Spouse"
            case .child: return ru ? "Ребёнок" : "Child"
            }
        }
    }

    enum AncestorSide: CaseIterable, Hashable {
        case root, partner
        func label(_ ru: Bool) -> String {
            switch self {
            case .root: return ru ? "Моей стороны" : "My side"
            case .partner: return ru ? "Стороны партнёра" : "Partner's side"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(isRussian ? "Имя" : "Name", text: $name)
                    TextField(isRussian ? "Годы (например 1975 — н.в.)" : "Years (e.g. 1975 – present)", text: $years)
                    Picker(isRussian ? "Пол" : "Sex", selection: $sex) {
                        Text(isRussian ? "Мужской" : "Male").tag(Sex.male)
                        Text(isRussian ? "Женский" : "Female").tag(Sex.female)
                    }
                    .pickerStyle(.segmented)
                }

                if !isEditing {
                    Section(isRussian ? "Кем приходится" : "Relation") {
                        Picker("", selection: $relationKind) {
                            ForEach(RelationKind.allCases, id: \.self) { kind in
                                Text(kind.label(isRussian)).tag(kind)
                            }
                        }
                        .pickerStyle(.segmented)

                        if relationKind == .parent && app.rootPartner != nil {
                            Picker(isRussian ? "Чья сторона" : "Whose side", selection: $ancestorSide) {
                                ForEach(AncestorSide.allCases, id: \.self) { side in
                                    Text(side.label(isRussian)).tag(side)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        if relationKind != .parent {
                            Toggle(isRussian ? "Бывш(ий/ая)" : "Former", isOn: $isEx)
                        }
                    }
                }

                Section(isRussian ? "Контакты (необязательно)" : "Contacts (optional)") {
                    TextField(isRussian ? "Телефон" : "Phone", text: $phone)
                    TextField("WhatsApp", text: $whatsapp)
                    TextField("Telegram", text: $telegram)
                    TextField("Instagram", text: $instagram)
                }
            }
            .navigationTitle(isEditing ? (isRussian ? "Изменить" : "Edit") : (isRussian ? "Новый человек" : "New person"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isRussian ? "Отмена" : "Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isRussian ? "Сохранить" : "Save") {
                        save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if case .edit(let person) = mode {
                name = person.name
                years = person.years
                sex = person.sex
                phone = person.phone ?? ""
                whatsapp = person.whatsapp ?? ""
                telegram = person.telegram ?? ""
                instagram = person.instagram ?? ""
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        switch mode {
        case .add:
            let role: PersonRole
            switch relationKind {
            case .parent: role = ancestorSide == .root ? .ancestorRoot : .ancestorPartner
            case .spouse: role = .rootPartner
            case .child: role = .child
            }
            let relationLabel: String
            switch relationKind {
            case .parent: relationLabel = isRussian ? "Родитель" : "Parent"
            case .spouse: relationLabel = isRussian ? "Супруг(а)" : "Spouse"
            case .child: relationLabel = isRussian ? "Ребёнок" : "Child"
            }
            app.addPerson(
                name: trimmedName, years: years, relation: relationLabel,
                sex: sex, role: role, isEx: isEx,
                phone: phone, whatsapp: whatsapp, telegram: telegram, instagram: instagram
            )
        case .edit(let person):
            app.updatePerson(
                person.id, name: trimmedName, years: years, relation: person.relation,
                sex: sex, phone: phone, whatsapp: whatsapp, telegram: telegram, instagram: instagram
            )
        }
    }
}
