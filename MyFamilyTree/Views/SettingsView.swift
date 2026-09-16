import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @State private var showResetConfirm = false

    private var isRussian: Bool { app.lang == .ru }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        if app.isPro {
                            Text(app.t(.proActiveTitle)).font(.system(size: 19, weight: .bold))
                            Text(app.t(.proActiveSub)).font(.system(size: 13)).foregroundStyle(.secondary)
                        } else {
                            Text(app.t(.proTitle)).font(.system(size: 19, weight: .bold))
                            Text(app.t(.proSub)).font(.system(size: 13)).foregroundStyle(.secondary)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("$4.99")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Theme.gold)
                                Text(app.lang == .ru ? "однократно" : "one-time")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Button(app.t(.buyPro)) { app.buyPro() }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.wine)
                            Button(app.t(.restore)) {}
                                .buttonStyle(.plain)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                }

                Section(app.t(.langGroup)) {
                    Picker(app.t(.langLabel), selection: $app.lang) {
                        Text("RU").tag(Lang.ru)
                        Text("EN").tag(Lang.en)
                    }
                    .pickerStyle(.segmented)
                }

                if !app.isPro {
                    Section(app.t(.freeGroup)) {
                        Text(app.t(.freeInfo1)).font(.system(size: 14)).foregroundStyle(.secondary)
                        Text(app.t(.freeInfo2)).font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Text(isRussian ? "Очистить все данные" : "Clear all data")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text(isRussian
                         ? "Удалит всё древо и всех людей. Покупка PRO останется."
                         : "Removes the whole tree and every person. Your PRO purchase stays.")
                }
            }
            .navigationTitle(app.t(.settingsTitle))
            .alert(isRussian ? "Очистить все данные?" : "Clear all data?", isPresented: $showResetConfirm) {
                Button(isRussian ? "Отмена" : "Cancel", role: .cancel) {}
                Button(isRussian ? "Очистить" : "Clear", role: .destructive) {
                    app.resetAllData()
                }
            } message: {
                Text(isRussian
                     ? "Это действие нельзя отменить."
                     : "This can't be undone.")
            }
        }
    }
}
