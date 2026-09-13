import SwiftUI

struct ExportView: View {
    @EnvironmentObject var app: AppState
    @State private var format = 0
    @State private var paperSize = 0
    @State private var showExportedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(app.lang == .ru ? "Формат файла" : "File format") {
                    Picker("", selection: $format) {
                        Text(app.t(.formatPDF)).tag(0)
                        Text(app.t(.formatPNG)).tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                Section(app.t(.paperSize)) {
                    Picker("", selection: $paperSize) {
                        Text("A4").tag(0)
                        Text("A3").tag(1)
                        Text("A2").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                if !app.isPro {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.t(.watermarkNote)).font(.system(size: 13)).foregroundStyle(Theme.wine)
                            Text(app.t(.removeInPro)).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.wine)
                        }
                    }
                }
                Section {
                    Button(app.t(.exportBtn)) {
                        // TODO: real PDF/PNG rendering once the tree canvas supports export
                        showExportedAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Theme.wine)
                }
            }
            .navigationTitle(app.t(.exportTitle))
        }
        .alert(app.lang == .ru ? "Экспорт (демо)" : "Export (demo)", isPresented: $showExportedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
