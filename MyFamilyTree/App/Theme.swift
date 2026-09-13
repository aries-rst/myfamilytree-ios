import SwiftUI

// Same palette as the Android app's CardColors.kt, so the iOS version
// reads as the same product, not a reskin.
enum Theme {
    static let paper = Color(hex: 0xE9E1CD)
    static let ink = Color(hex: 0x2C241C)
    static let wine = Color(hex: 0x7A3030)
    static let gold = Color(hex: 0xA9813F)
    static let male = Color(hex: 0x4C6270)
    static let female = Color(hex: 0xA2555A)

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
