import SwiftUI

struct PersonDetailSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let person: Person

    private var contactIcons: [String] {
        var icons: [String] = []
        if person.phone != nil { icons.append("phone.fill") }
        if person.whatsapp != nil { icons.append("message.fill") }
        if person.telegram != nil { icons.append("paperplane.fill") }
        if person.instagram != nil { icons.append("camera.fill") }
        return icons
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Theme.paper)
                    Text(person.avatarInitials).font(.system(size: 18, weight: .bold))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name).font(.system(size: 19, weight: .bold))
                    Text("\(person.years) · \(person.relation)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            if !contactIcons.isEmpty {
                HStack(spacing: 10) {
                    ForEach(contactIcons, id: \.self) { icon in
                        Image(systemName: icon)
                            .frame(width: 38, height: 38)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Theme.cardShadow, radius: 3, y: 1)
                    }
                }
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    // TODO: real edit form once persistence lands
                } label: {
                    Text(app.lang == .ru ? "Изменить" : "Edit")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.wine)

                Button(app.t(.close)) { dismiss() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
