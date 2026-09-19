import SwiftUI

/// A selectable color scheme for daily use. "classic" matches the Android
/// app's CardColors.kt palette (the previous fixed look); the others are
/// alternates the user can switch to in Settings. No wallpapers/photos here —
/// only color, per the family-tree app's simpler, print-focused design.
enum FamilyPalette: String, CaseIterable, Identifiable, Codable {
    case classic, midnight, forest, blossom

    var id: String { rawValue }

    var paper: Color {
        switch self {
        case .classic: return Color(hex: 0xE9E1CD)
        case .midnight: return Color(hex: 0xE4E8F0)
        case .forest: return Color(hex: 0xE6EEE1)
        case .blossom: return Color(hex: 0xF8EAEE)
        }
    }
    var ink: Color {
        switch self {
        case .classic: return Color(hex: 0x2C241C)
        case .midnight: return Color(hex: 0x1C2333)
        case .forest: return Color(hex: 0x1E2B1F)
        case .blossom: return Color(hex: 0x33232A)
        }
    }
    var wine: Color {
        switch self {
        case .classic: return Color(hex: 0x7A3030)
        case .midnight: return Color(hex: 0x33507D)
        case .forest: return Color(hex: 0x3D6B49)
        case .blossom: return Color(hex: 0xA14E71)
        }
    }
    var gold: Color {
        switch self {
        case .classic: return Color(hex: 0xA9813F)
        case .midnight: return Color(hex: 0x4E7BA8)
        case .forest: return Color(hex: 0x74924D)
        case .blossom: return Color(hex: 0xC98A6B)
        }
    }
    var male: Color {
        switch self {
        case .classic: return Color(hex: 0x4C6270)
        case .midnight: return Color(hex: 0x3C5C8A)
        case .forest: return Color(hex: 0x3F6E55)
        case .blossom: return Color(hex: 0x5C6E8C)
        }
    }
    var female: Color {
        switch self {
        case .classic: return Color(hex: 0xA2555A)
        case .midnight: return Color(hex: 0x6A72A8)
        case .forest: return Color(hex: 0x7C9757)
        case .blossom: return Color(hex: 0xB1587C)
        }
    }

    func label(_ lang: Lang) -> String {
        switch (self, lang) {
        case (.classic, .ru): return "Классика"
        case (.classic, .en): return "Classic"
        case (.midnight, .ru): return "Полночь"
        case (.midnight, .en): return "Midnight"
        case (.forest, .ru): return "Лес"
        case (.forest, .en): return "Forest"
        case (.blossom, .ru): return "Цветение"
        case (.blossom, .en): return "Blossom"
        }
    }
}

// Same palette as the Android app's CardColors.kt by default ("classic"), so
// the iOS version still reads as the same product out of the box. Every other
// file keeps reading `Theme.wine` / `Theme.gold` / etc. unchanged — only what
// those resolve to changes at runtime, driven by `Theme.current`, which
// AppState keeps in sync with the user's chosen palette.
enum Theme {
    static var current: FamilyPalette = .classic

    static var paper: Color { current.paper }
    static var ink: Color { current.ink }
    static var wine: Color { current.wine }
    static var gold: Color { current.gold }
    static var male: Color { current.male }
    static var female: Color { current.female }

    static let cardShadow = Color.black.opacity(0.14)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
