import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var lang: Lang = .en
    @Published var isPro: Bool = false
    @Published var exesShown: Bool = false
    @Published var people: [Person] = [
        Person(
            id: UUID().uuidString,
            name: "",
            years: "",
            relation: "",
            avatarInitials: "?",
            sex: .male,
            role: .root
        )
    ]

    func t(_ key: L) -> String {
        Strings.t(key, lang)
    }

    var peopleCount: Int { people.count }

    var canAddPerson: Bool {
        isPro || peopleCount < 7
    }

    var rootPartner: Person? {
        people.first(where: { $0.role == .rootPartner && !$0.isExSpouse })
    }

    func addPerson(
        name: String,
        years: String,
        relation: String,
        sex: Sex,
        role: PersonRole,
        isEx: Bool,
        phone: String,
        whatsapp: String,
        telegram: String,
        instagram: String
    ) {
        guard canAddPerson else { return }
        var finalIsEx = isEx
        if role == .rootPartner && !isEx && rootPartner != nil {
            finalIsEx = true
        }
        let person = Person(
            id: UUID().uuidString,
            name: name,
            years: years,
            relation: relation,
            avatarInitials: Self.initials(from: name),
            sex: sex,
            role: role,
            phone: phone.isEmpty ? nil : phone,
            whatsapp: whatsapp.isEmpty ? nil : whatsapp,
            telegram: telegram.isEmpty ? nil : telegram,
            instagram: instagram.isEmpty ? nil : instagram,
            isExSpouse: role == .rootPartner ? finalIsEx : false,
            isExChild: role == .child ? isEx : false
        )
        people.append(person)
    }

    func updatePerson(
        _ id: String,
        name: String,
        years: String,
        relation: String,
        sex: Sex,
        phone: String,
        whatsapp: String,
        telegram: String,
        instagram: String
    ) {
        guard let index = people.firstIndex(where: { $0.id == id }) else { return }
        people[index].name = name
        people[index].years = years
        people[index].relation = relation
        people[index].sex = sex
        people[index].avatarInitials = Self.initials(from: name)
        people[index].phone = phone.isEmpty ? nil : phone
        people[index].whatsapp = whatsapp.isEmpty ? nil : whatsapp
        people[index].telegram = telegram.isEmpty ? nil : telegram
        people[index].instagram = instagram.isEmpty ? nil : instagram
    }

    /// Человека нельзя удалить, пока у него есть дети в дереве — как в Android-версии.
    func canRemove(_ id: String) -> Bool {
        guard let person = people.first(where: { $0.id == id }) else { return false }
        if person.role == .root {
            return false
        }
        if person.role == .rootPartner {
            return !people.contains { $0.role == .child }
        }
        return true
    }

    func removePerson(_ id: String) {
        guard canRemove(id) else { return }
        people.removeAll { $0.id == id }
    }

    func buyPro() {
        isPro = true
    }

    static func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }
}
