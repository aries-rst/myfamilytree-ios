import SwiftUI

struct LimitPaywallSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    private var isRussian: Bool { app.lang == .ru }

    var body: some View {
        VStack(spacing: 16) {
            Text(isRussian ? "Достигнут лимит FREE" : "FREE limit reached")
                .font(.system(size: 20, weight: .bold))
            Text(isRussian
                 ? "В бесплатной версии можно добавить до 7 человек. Купите PRO разово, чтобы снять ограничение."
                 : "The free version allows up to 7 people. Buy PRO once to remove the limit.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            Button {
                app.buyPro()
                dismiss()
            } label: {
                Text(isRussian ? "Купить PRO" : "Buy PRO").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.wine)

            Button(isRussian ? "Позже" : "Later") { dismiss() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
}
