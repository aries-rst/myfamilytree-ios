import SwiftUI
import UIKit

struct TreeView: View {
    @EnvironmentObject var app: AppState

    @State private var zoom: CGFloat = 1.0
    @GestureState private var pinchDelta: CGFloat = 1.0
    @State private var naturalSize: CGSize = .zero
    @State private var selectedPerson: SelectedPerson?
    @State private var formMode: PersonFormMode?
    @State private var shareItem: TreeShareItem?

    private var isRussian: Bool { app.lang == .ru }
    private var displayedZoom: CGFloat { min(1.4, max(0.6, zoom * pinchDelta)) }

    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                FamilyBranchView(
                    node: app.root, isRoot: true,
                    onTapPerson: { person, nodeId in selectedPerson = SelectedPerson(nodeId: nodeId, person: person) },
                    onAddChild: { nodeId in formMode = .addChild(nodeId: nodeId) },
                    onAddSpouse: { nodeId in formMode = .addSpouse(nodeId: nodeId) },
                    onAddParent: { formMode = .addParent },
                    exesShown: app.exesShown, isRussian: isRussian
                )
                .padding(40)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: TreeSizePreferenceKey.self, value: geo.size)
                    }
                )
                .scaleEffect(displayedZoom, anchor: .topLeading)
                .frame(width: naturalSize.width * displayedZoom, height: naturalSize.height * displayedZoom)
            }
            .onPreferenceChange(TreeSizePreferenceKey.self) { naturalSize = $0 }
            .background(Theme.paper.opacity(0.4))
            .navigationTitle(isRussian ? "Семейное древо" : "Family Tree")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(isRussian ? "Экспорт в PNG" : "Export as PNG") { exportPNG() }
                        Button(isRussian ? "Экспорт в PDF" : "Export as PDF") { exportPDF() }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(app.lang == .ru ? "RU" : "EN") {
                        app.lang = app.lang == .ru ? .en : .ru
                    }
                    .font(.system(size: 13, weight: .bold))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(isRussian ? "Бывшие" : "Exes") {
                        withAnimation { app.exesShown.toggle() }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .tint(Theme.wine)
                }
            }
        }
        .simultaneousGesture(
            MagnificationGesture()
                .updating($pinchDelta) { value, state, _ in state = value }
                .onEnded { value in zoom = min(1.4, max(0.6, zoom * value)) }
        )
        .sheet(item: $selectedPerson) { sel in
            PersonDetailSheet(nodeId: sel.nodeId, person: sel.person)
        }
        .sheet(item: $formMode) { mode in
            AddPersonSheet(mode: mode)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
        .sheet(isPresented: $app.showLimitSheet) {
            LimitPaywallSheet()
        }
    }

    @MainActor
    private func renderImage() -> UIImage? {
        let content = FamilyBranchView(
            node: app.root, isRoot: false,
            onTapPerson: { _, _ in }, onAddChild: { _ in }, onAddSpouse: { _ in }, onAddParent: {},
            exesShown: app.exesShown, isRussian: isRussian, showControls: false
        )
        .padding(30)
        .background(Color.white)
        .environmentObject(app)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        return renderer.uiImage
    }

    private func exportPNG() {
        guard let image = renderImage(), let data = image.pngData() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("family-tree-\(Int(Date().timeIntervalSince1970)).png")
        do { try data.write(to: url); shareItem = TreeShareItem(url: url) } catch {}
    }

    private func exportPDF() {
        guard let image = renderImage() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("family-tree-\(Int(Date().timeIntervalSince1970)).pdf")
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        do {
            try pdfRenderer.writePDF(to: url) { ctx in ctx.beginPage(); image.draw(at: .zero) }
            shareItem = TreeShareItem(url: url)
        } catch {}
    }
}

private struct TreeSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

struct TreeShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct SelectedPerson: Identifiable {
    var id: String { person.id }
    let nodeId: UUID
    let person: FamilyPerson
}

struct FamilyBranchView: View {
    let node: FamilyNode
    let isRoot: Bool
    let onTapPerson: (FamilyPerson, UUID) -> Void
    let onAddChild: (UUID) -> Void
    let onAddSpouse: (UUID) -> Void
    let onAddParent: () -> Void
    let exesShown: Bool
    let isRussian: Bool
    var showControls: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            if isRoot, showControls, let primary = node.people.first, !primary.name.isEmpty {
                Button { onAddParent() } label: {
                    Text((isRussian ? "+ Добавить родителей \"" : "+ Add parents of \"") + primary.name + "\"")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Theme.gold)
                connector
            }

            HStack(spacing: 0) {
                ForEach(Array(node.people.enumerated()), id: \.element.id) { index, person in
                    if index == 0 || !person.isEx || exesShown {
                        if index > 0 { Divider().frame(height: 32).padding(.horizontal, 4) }
                        personChip(person, nodeId: node.id)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Theme.cardShadow, radius: 3, y: 1)

            if showControls {
                HStack(spacing: 14) {
                    Button { onAddChild(node.id) } label: {
                        Text(isRussian ? "+ ребёнок" : "+ child").font(.system(size: 12, weight: .semibold))
                    }
                    if node.people.filter({ !$0.isEx }).count < 2 {
                        Button { onAddSpouse(node.id) } label: {
                            Text(isRussian ? "+ супруг(а)" : "+ spouse").font(.system(size: 12, weight: .semibold))
                        }
                    }
                }
                .foregroundStyle(Theme.gold)
            }

            if !node.children.isEmpty {
                connector
                HStack(alignment: .top, spacing: 24) {
                    ForEach(node.children) { child in
                        FamilyBranchView(
                            node: child, isRoot: false,
                            onTapPerson: onTapPerson, onAddChild: onAddChild, onAddSpouse: onAddSpouse, onAddParent: onAddParent,
                            exesShown: exesShown, isRussian: isRussian, showControls: showControls
                        )
                    }
                }
            }
        }
    }

    private func personChip(_ person: FamilyPerson, nodeId: UUID) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill((person.sex == .male ? Theme.male : Theme.female).opacity(0.15))
                if let data = person.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill().clipShape(Circle())
                } else {
                    Text(person.avatarInitials)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(person.sex == .male ? Theme.male : Theme.female)
                }
            }
            .frame(width: 38, height: 38)
            .overlay(Circle().stroke(person.sex == .male ? Theme.male : Theme.female, lineWidth: 2))

            Text(person.name.isEmpty ? "—" : person.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.ink)
            if !person.years.isEmpty {
                Text(person.years).font(.system(size: 10)).foregroundStyle(Theme.ink.opacity(0.6))
            }
            if person.isEx {
                Text(isRussian ? "бывш." : "ex")
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Theme.female)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 6)
        .onTapGesture { onTapPerson(person, nodeId) }
    }

    private var connector: some View {
        Rectangle().fill(Theme.ink.opacity(0.22)).frame(width: 2, height: 14)
    }
}
