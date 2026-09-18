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
    // Keyed by a FamilyPerson.id from `people`: that person's own parent pair (their
    // mother/father), stored as its own small node. This lets two people in the same
    // couple each grow their own ancestry upward, independently of one another.
    var ancestors: [String: FamilyNode]

    init(id: UUID = UUID(), people: [FamilyPerson], children: [FamilyNode] = [], ancestors: [String: FamilyNode] = [:]) {
        self.id = id
        self.people = people
        self.children = children
        self.ancestors = ancestors
    }

    private enum CodingKeys: String, CodingKey {
        case id, people, children, ancestors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        people = try container.decode([FamilyPerson].self, forKey: .people)
        children = try container.decode([FamilyNode].self, forKey: .children)
        // decodeIfPresent so trees saved before this field existed still load fine.
        ancestors = try container.decodeIfPresent([String: FamilyNode].self, forKey: .ancestors) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(people, forKey: .people)
        try container.encode(children, forKey: .children)
        try container.encode(ancestors, forKey: .ancestors)
    }
}

extension FamilyNode {
    func updating(id targetId: UUID, transform: (inout FamilyNode) -> Void) -> FamilyNode {
        var copy = self
        if copy.id == targetId {
            transform(&copy)
            return copy
        }
        copy.children = copy.children.map { $0.updating(id: targetId, transform: transform) }
        for (key, node) in copy.ancestors {
            copy.ancestors[key] = node.updating(id: targetId, transform: transform)
        }
        return copy
    }

    func appendingChild(to parentId: UUID, _ child: FamilyNode) -> FamilyNode {
        var copy = self
        if copy.id == parentId {
            copy.children.append(child)
            return copy
        }
        copy.children = copy.children.map { $0.appendingChild(to: parentId, child) }
        for (key, node) in copy.ancestors {
            copy.ancestors[key] = node.appendingChild(to: parentId, child)
        }
        return copy
    }

    func removingNode(id targetId: UUID) -> FamilyNode {
        var copy = self
        copy.children.removeAll { $0.id == targetId }
        copy.children = copy.children.map { $0.removingNode(id: targetId) }
        for (key, node) in copy.ancestors {
            if node.id == targetId {
                copy.ancestors.removeValue(forKey: key)
            } else {
                copy.ancestors[key] = node.removingNode(id: targetId)
            }
        }
        return copy
    }

    func node(withId targetId: UUID) -> FamilyNode? {
        if id == targetId { return self }
        for child in children {
            if let found = child.node(withId: targetId) { return found }
        }
        for ancestorNode in ancestors.values {
            if let found = ancestorNode.node(withId: targetId) { return found }
        }
        return nil
    }

    func countAll() -> Int {
        people.count
            + children.reduce(0) { $0 + $1.countAll() }
            + ancestors.values.reduce(0) { $0 + $1.countAll() }
    }
}
