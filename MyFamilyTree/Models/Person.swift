import Foundation

enum Sex: Hashable, Codable {
    case male, female
}

struct FamilyPerson: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var years: String = ""
    var sex: Sex = .male
    var isEx: Bool = false
    var phone: String? = nil
    var whatsapp: String? = nil
    var telegram: String? = nil
    var instagram: String? = nil
    var photoData: Data? = nil

    var avatarInitials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }
}

struct FamilyNode: Identifiable, Codable, Hashable {
    let id: UUID
    var people: [FamilyPerson]
    var children: [FamilyNode]

    init(id: UUID = UUID(), people: [FamilyPerson], children: [FamilyNode] = []) {
        self.id = id
        self.people = people
        self.children = children
    }
}

extension FamilyNode {
    func updating(id targetId: UUID, transform: (inout FamilyNode) -> Void) -> FamilyNode {
        var copy = self
        if copy.id == targetId {
            transform(&copy)
        } else {
            copy.children = copy.children.map { $0.updating(id: targetId, transform: transform) }
        }
        return copy
    }

    func appendingChild(to parentId: UUID, _ child: FamilyNode) -> FamilyNode {
        var copy = self
        if copy.id == parentId {
            copy.children.append(child)
        } else {
            copy.children = copy.children.map { $0.appendingChild(to: parentId, child) }
        }
        return copy
    }

    func removingNode(id targetId: UUID) -> FamilyNode {
        var copy = self
        copy.children.removeAll { $0.id == targetId }
        copy.children = copy.children.map { $0.removingNode(id: targetId) }
        return copy
    }

    func node(withId targetId: UUID) -> FamilyNode? {
        if id == targetId { return self }
        for child in children {
            if let found = child.node(withId: targetId) { return found }
        }
        return nil
    }

    func countAll() -> Int {
        people.count + children.reduce(0) { $0 + $1.countAll() }
    }
}
