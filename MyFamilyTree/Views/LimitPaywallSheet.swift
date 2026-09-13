import SwiftUI

struct LimitPaywallSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(app.t(.limitTitle))
                .font(.system(size: 20, weight: .bold))
            Text(app.t(.limitText))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            Button {
                app.buyPro()
                dismiss()
            } label: {
                Text(app.t(.limitBuy)).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.wine)

            Button(app.t(.later)) { dismiss() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
}
