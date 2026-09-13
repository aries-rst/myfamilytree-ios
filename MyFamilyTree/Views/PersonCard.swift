import SwiftUI

struct PersonCard: View {
    let person: Person
    var compact: Bool = false
    var emphasized: Bool = false

    private var borderColor: Color {
        person.sex == .male ? Theme.male : Theme.female
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Theme.paper)
                    .overlay(Circle().stroke(Theme.ink.opacity(0.15), lineWidth: 2))
                Text(person.avatarInitials)
                    .font(.system(size: compact ? 12 : 14, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }
            .frame(width: compact ? 34 : 42, height: compact ? 34 : 42)

            Text(person.name)
                .font(.system(size: compact ? 12 : 14, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
            Text(person.years)
                .font(.system(size: 11))
                .foregroundStyle(Theme.ink.opacity(0.6))
        }
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 8 : (emphasized ? 14 : 10))
        .frame(minWidth: compact ? 84 : (emphasized ? 118 : 100))
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(borderColor)
                .frame(height: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.horizontal, 2)
        }
        .shadow(color: Theme.cardShadow, radius: 3, y: 1)
    }
}
