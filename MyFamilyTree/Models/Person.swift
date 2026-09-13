import Foundation

enum Sex: Hashable {
    case male, female
}

struct Person: Identifiable, Hashable {
    let id: String
    var name: String
    var years: String
    var relation: String
    var avatarInitials: String
    var sex: Sex
    var phone: String?
    var whatsapp: String?
    var telegram: String?
    var instagram: String?
    var isExSpouse: Bool = false
    var isExChild: Bool = false
}

// Same demo family used in the HTML prototype, so the two stay recognizably
// in sync while a real persistence layer (SwiftData) isn't wired up yet.
enum DemoFamily {
    static let fatherA = Person(id: "p-father-a", name: "Шариф Каримов", years: "1948 – 2015", relation: "Отец Азиза", avatarInitials: "ШК", sex: .male)
    static let motherA = Person(id: "p-mother-a", name: "Матлюба Каримова", years: "р. 1950", relation: "Мать Азиза", avatarInitials: "МК", sex: .female)
    static let fatherN = Person(id: "p-father-n", name: "Анвар Расулов", years: "1945 – 2020", relation: "Отец Нилуфар", avatarInitials: "АР", sex: .male)
    static let motherN = Person(id: "p-mother-n", name: "Дилором Расулова", years: "р. 1949", relation: "Мать Нилуфар", avatarInitials: "ДР", sex: .female)
    static let aziz = Person(id: "p-aziz", name: "Азиз Каримов", years: "р. 1975", relation: "Корень древа", avatarInitials: "АК", sex: .male,
                             phone: "+998 90 111-22-33", whatsapp: "+998 90 111-22-33", telegram: "@aziz_karimov")
    static let nilufar = Person(id: "p-nilufar", name: "Нилуфар Каримова", years: "р. 1978", relation: "Супруга Азиза", avatarInitials: "НК", sex: .female,
                                 phone: "+998 90 444-55-66", instagram: "@nilufar.k")
    static let gulnora = Person(id: "p-gulnora", name: "Гулнора Исмаилова", years: "р. 1976", relation: "Бывшая супруга Азиза", avatarInitials: "ГИ", sex: .female, isExSpouse: true)
    static let sardor = Person(id: "p-sardor", name: "Сардор Каримов", years: "р. 2005", relation: "Сын", avatarInitials: "СК", sex: .male)
    static let dilnoza = Person(id: "p-dilnoza", name: "Дилноза Каримова", years: "р. 2008", relation: "Дочь", avatarInitials: "ДК", sex: .female)
    static let jasur = Person(id: "p-jasur", name: "Жасур Каримов", years: "р. 2000", relation: "Сын (от первого брака)", avatarInitials: "ЖК", sex: .male, isExChild: true)

    static let all: [Person] = [fatherA, motherA, fatherN, motherN, aziz, nilufar, gulnora, sardor, dilnoza, jasur]
    static let ancestorsA: [Person] = [fatherA, motherA]
    static let ancestorsN: [Person] = [fatherN, motherN]
    static let children: [Person] = [sardor, dilnoza, jasur]
}
