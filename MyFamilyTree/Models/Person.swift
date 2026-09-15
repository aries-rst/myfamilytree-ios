import Foundation

enum Sex: Hashable {
    case male, female
}

enum PersonRole: Hashable {
    case root
    case rootPartner
    case ancestorRoot
    case ancestorPartner
    case child
}

struct Person: Identifiable, Hashable {
    let id: String
    var name: String
    var years: String
    var relation: String
    var avatarInitials: String
    var sex: Sex
    var role: PersonRole
    var phone: String?
    var whatsapp: String?
    var telegram: String?
    var instagram: String?
    var isExSpouse: Bool = false
    var isExChild: Bool = false
}
