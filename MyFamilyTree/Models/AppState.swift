import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var lang: Lang = .ru
    @Published var isPro: Bool = false
    @Published var peopleCount: Int = 9
    @Published var exesShown: Bool = false
    @Published var people: [Person] = DemoFamily.all

    func t(_ key: L) -> String {
        Strings.t(key, lang)
    }

    var canAddPerson: Bool {
        isPro || peopleCount < 7
    }

    func addPerson() {
        peopleCount += 1
    }

    func buyPro() {
        isPro = true
    }
}
