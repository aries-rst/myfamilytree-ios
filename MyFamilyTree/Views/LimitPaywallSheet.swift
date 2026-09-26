import SwiftUI

struct LimitPaywallSheet: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var store: StoreManager
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
                Task {
                    await store.purchase()
                    if app.isPro { dismiss() }
                }
            } label: {
                if store.isPurchasing {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text(isRussian ? "Купить PRO" : "Buy PRO").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.wine)
            .disabled(store.isPurchasing)

            if let error = store.lastError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(isRussian ? "Позже" : "Later") { dismiss() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(store.isPurchasing)
        }
        .padding(20)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}
