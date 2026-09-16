import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var lang: Lang = .en { didSet { save() } }
    @Published var isPro: Bool = false { didSet { save() } }
    @Published var exesShown: Bool = false
    @Published var showLimitSheet: Bool = false
    @Published var root: FamilyNode = FamilyNode(people: [FamilyPerson(name: "", sex: .male)]) { didSet { save() } }
    @Published var hasParentTier: Bool = false { didSet { save() } }

    private let rootKey = "myfamilytree.root"
    private let isProKey = "myfamilytree.isPro"
    private let langKey = "myfamilytree.lang"
    private let hasParentTierKey = "myfamilytree.hasParentTier"

    init() {
        load()
    }

    func t(_ key: L) -> String {
        Strings.t(key, lang)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(root) {
            UserDefaults.standard.set(data, forKey: rootKey)
        }
        UserDefaults.standard.set(isPro, forKey: isProKey)
        UserDefaults.standard.set(lang == .ru ? "ru" : "en", forKey: langKey)
        UserDefaults.standard.set(hasParentTier, forKey: hasParentTierKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: rootKey),
           let decoded = try? JSONDecoder().decode(FamilyNode.self, from: data) {
            root = decoded
        }
        isPro = UserDefaults.standard.bool(forKey: isProKey)
        if let langRaw = UserDefaults.standard.string(forKey: langKey) {
            lang = langRaw == "ru" ? .ru : .en
        }
        hasParentTier = UserDefaults.standard.bool(forKey: hasParentTierKey)
    }

    func resetAllData() {
        root = FamilyNode(people: [FamilyPerson(name: "", sex: .male)])
        hasParentTier = false
    }

    var peopleCount: Int { root.countAll() }
    var canAddPerson: Bool { isPro || peopleCount < 7 }

    func addChild(to nodeId: UUID, person: FamilyPerson) {
        guard canAddPerson else { showLimitSheet = true; return }
        root = root.appendingChild(to: nodeId, FamilyNode(people: [person]))
    }

    func addSpouse(to nodeId: UUID, person: FamilyPerson) {
        guard canAddPerson else { showLimitSheet = true; return }
        root = root.updating(id: nodeId) { node in
            node.people.append(person)
        }
    }

    func addParent(person: FamilyPerson) {
        guard !hasParentTier else { return }
        guard canAddPerson else { showLimitSheet = true; return }
        root = FamilyNode(people: [person], children: [root])
        hasParentTier = true
    }

    func updatePerson(
        nodeId: UUID, personId: String, name: String, years: String, sex: Sex, isEx: Bool,
        phone: String, whatsapp: String, telegram: String, instagram: String, photoData: Data?
    ) {
        root = root.updating(id: nodeId) { node in
            guard let idx = node.people.firstIndex(where: { $0.id == personId }) else { return }
            node.people[idx].name = name
            node.people[idx].years = years
            node.people[idx].sex = sex
            node.people[idx].isEx = idx == 0 ? false : isEx
            node.people[idx].phone = phone.isEmpty ? nil : phone
            node.people[idx].whatsapp = whatsapp.isEmpty ? nil : whatsapp
            node.people[idx].telegram = telegram.isEmpty ? nil : telegram
            node.people[idx].instagram = instagram.isEmpty ? nil : instagram
            node.people[idx].photoData = photoData
        }
    }

    func canRemovePerson(nodeId: UUID, personId: String) -> Bool {
        guard let node = root.node(withId: nodeId),
              let idx = node.people.firstIndex(where: { $0.id == personId }) else { return false }
        if idx == 0 {
            if nodeId == root.id { return false }
            return node.children.isEmpty
        }
        return true
    }

    func removePerson(nodeId: UUID, personId: String) {
        guard canRemovePerson(nodeId: nodeId, personId: personId),
              let node = root.node(withId: nodeId),
              let idx = node.people.firstIndex(where: { $0.id == personId }) else { return }
        if idx == 0 {
            root = root.removingNode(id: nodeId)
        } else {
            root = root.updating(id: nodeId) { node in
                node.people.removeAll { $0.id == personId }
            }
        }
    }

    func buyPro() {
        isPro = true
    }
}
