import SwiftUI
import UIKit

struct ExportView: View {
    @EnvironmentObject var app: AppState
    @State private var format = 0
    @State private var paperSize = 0
    @State private var shareItem: TreeShareItem?

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
                        if format == 0 { exportPDF() } else { exportPNG() }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Theme.wine)
                }
            }
            .navigationTitle(app.t(.exportTitle))
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    @MainActor
    private func renderImage() -> UIImage? {
        let content = FamilyBranchView(
            node: app.root, isRoot: false,
            onTapPerson: { _, _ in }, onAddChild: { _ in }, onAddSpouse: { _ in }, onAddParent: { _, _ in },
            exesShown: app.exesShown, isRussian: app.lang == .ru, showControls: false
        )
        .padding(30)
        .background(Color.white)
        .environmentObject(app)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        return renderer.uiImage
    }

    private func watermarked(_ image: UIImage) -> UIImage {
        guard !app.isPro else { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            let text = "MyFamilyTree · FREE" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: image.size.width * 0.05),
                .foregroundColor: UIColor.black.withAlphaComponent(0.12)
            ]
            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: image.size.width / 2, y: image.size.height / 2)
            ctx.cgContext.rotate(by: -.pi / 6)
            let size = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: -size.width / 2, y: -size.height / 2), withAttributes: attrs)
            ctx.cgContext.restoreGState()
        }
    }

    private func exportPNG() {
        guard let image = renderImage() else { return }
        let final = watermarked(image)
        guard let data = final.pngData() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("family-tree-\(Int(Date().timeIntervalSince1970)).png")
        do { try data.write(to: url); shareItem = TreeShareItem(url: url) } catch {}
    }

    private func exportPDF() {
        guard let image = renderImage() else { return }
        let final = watermarked(image)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("family-tree-\(Int(Date().timeIntervalSince1970)).pdf")
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: final.size))
        do {
            try pdfRenderer.writePDF(to: url) { ctx in ctx.beginPage(); final.draw(at: .zero) }
            shareItem = TreeShareItem(url: url)
        } catch {}
    }
}
