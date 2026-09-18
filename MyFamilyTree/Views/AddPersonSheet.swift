import SwiftUI
import PhotosUI

enum PersonFormMode: Identifiable {
    case addChild(nodeId: UUID)
    case addSpouse(nodeId: UUID)
    case addParent(nodeId: UUID, personId: String, personName: String)
    case edit(nodeId: UUID, person: FamilyPerson)

    var id: String {
        switch self {
        case .addChild(let id): return "addChild-\(id)"
        case .addSpouse(let id): return "addSpouse-\(id)"
        case .addParent(let id, let personId, _): return "addParent-\(id)-\(personId)"
        case .edit(let id, let p): return "edit-\(id)-\(p.id)"
        }
    }
}

struct AddPersonSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    let mode: PersonFormMode

    @State private var name: String = ""
    @State private var years: String = ""
    @State private var sex: Sex = .male
    @State private var isEx: Bool = false
    @State private var phone: String = ""
    @State private var whatsapp: String = ""
    @State private var telegram: String = ""
    @State private var instagram: String = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    private var isRussian: Bool { app.lang == .ru }

    private var showExToggle: Bool {
        switch mode {
        case .addSpouse: return true
        case .edit(let nodeId, let existing):
            guard let node = app.root.node(withId: nodeId) else { return false }
            return node.people.first?.id != existing.id
        default: return false
        }
    }

    private var sheetTitle: String {
        switch mode {
        case .addChild: return isRussian ? "Добавить ребёнка" : "Add child"
        case .addSpouse: return isRussian ? "Добавить супруга(у)" : "Add spouse"
        case .addParent(_, _, let name): return (isRussian ? "Родители — " : "Parents of ") + name
        case .edit: return isRussian ? "Изменить" : "Edit"
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
                    if showExToggle {
                        Toggle(isRussian ? "Бывш(ий/ая)" : "Former", isOn: $isEx)
                    }
                }

                Section(isRussian ? "Фото" : "Photo") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "photo.badge.plus").font(.system(size: 22))
                            }
                            Text(isRussian ? "Выбрать фото" : "Choose photo")
                        }
                    }
                    .onChange(of: photoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
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
            .navigationTitle(sheetTitle)
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
            if case .edit(_, let person) = mode {
                name = person.name
                years = person.years
                sex = person.sex
                isEx = person.isEx
                phone = person.phone ?? ""
                whatsapp = person.whatsapp ?? ""
                telegram = person.telegram ?? ""
                instagram = person.instagram ?? ""
                photoData = person.photoData
            }
        }
    }

    private func makePerson(_ name: String) -> FamilyPerson {
        FamilyPerson(
            name: name, years: years, sex: sex, isEx: isEx,
            phone: phone.isEmpty ? nil : phone,
            whatsapp: whatsapp.isEmpty ? nil : whatsapp,
            telegram: telegram.isEmpty ? nil : telegram,
            instagram: instagram.isEmpty ? nil : instagram,
            photoData: photoData
        )
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        switch mode {
        case .addChild(let nodeId):
            app.addChild(to: nodeId, person: makePerson(trimmedName))
        case .addSpouse(let nodeId):
            app.addSpouse(to: nodeId, person: makePerson(trimmedName))
        case .addParent(let nodeId, let personId, _):
            app.addParent(to: nodeId, personId: personId, person: makePerson(trimmedName))
        case .edit(let nodeId, let existing):
            app.updatePerson(
                nodeId: nodeId, personId: existing.id, name: trimmedName, years: years, sex: sex, isEx: isEx,
                phone: phone, whatsapp: whatsapp, telegram: telegram, instagram: instagram, photoData: photoData
            )
        }
    }
}
