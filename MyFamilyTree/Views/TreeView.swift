import SwiftUI
import UIKit

struct TreeView: View {
    @EnvironmentObject var app: AppState

    @State private var zoom: CGFloat = 1.0
    @GestureState private var pinchDelta: CGFloat = 1.0
    @State private var naturalSize: CGSize = .zero
    @State private var selectedPerson: Person?
    @State private var showAddSheet = false
    @State private var shareItem: TreeShareItem?

    private var isRussian: Bool { app.lang == .ru }

    private var displayedZoom: CGFloat {
        min(1.4, max(0.6, zoom * pinchDelta))
    }

    private var rootPerson: Person {
        app.people.first(where: { $0.role == .root }) ?? Person(id: "root", name: "", years: "", relation: "", avatarInitials: "?", sex: .male, role: .root)
    }
    private var partners: [Person] { app.people.filter { $0.role == .rootPartner } }
    private var ancestorsRoot: [Person] { app.people.filter { $0.role == .ancestorRoot } }
    private var ancestorsPartner: [Person] { app.people.filter { $0.role == .ancestorPartner } }
    private var children: [Person] { app.people.filter { $0.role == .child } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView([.horizontal, .vertical]) {
                    treeCanvas
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

                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(Theme.gold)
                        .clipShape(Circle())
                        .shadow(color: Theme.gold.opacity(0.5), radius: 10, y: 4)
                }
                .padding(20)
            }
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
        .sheet(item: $selectedPerson) { person in
            PersonDetailSheet(person: person)
        }
        .sheet(isPresented: $showAddSheet) {
            AddPersonSheet(mode: .add)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    private var treeCanvas: some View {
        VStack(spacing: 16) {
            if !ancestorsRoot.isEmpty || !ancestorsPartner.isEmpty {
                HStack(alignment: .top, spacing: 28) {
                    if !ancestorsRoot.isEmpty {
                        ancestorGroup(label: isRussian ? "Моя сторона" : "My side", people: ancestorsRoot)
                    }
                    if !ancestorsPartner.isEmpty {
                        ancestorGroup(label: isRussian ? "Сторона партнёра" : "Partner's side", people: ancestorsPartner)
                    }
                }
                connector
            }

            HStack(spacing: 10) {
                PersonCard(person: rootPerson, emphasized: true)
                    .onTapGesture { selectedPerson = rootPerson }
                ForEach(partners) { partner in
                    if !partner.isExSpouse || app.exesShown {
                        Group {
                            Text("⚭").font(.system(size: 20)).foregroundStyle(Theme.gold)
                            PersonCard(person: partner, emphasized: true)
                                .overlay(alignment: .top) {
                                    if partner.isExSpouse {
                                        Text(partner.sex == .male
                                             ? (isRussian ? "бывший супруг" : "ex-spouse")
                                             : (isRussian ? "бывшая супруга" : "ex-spouse"))
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Theme.female)
                                            .foregroundStyle(.white)
                                            .clipShape(Capsule())
                                            .offset(y: -9)
                                    }
                                }
                                .onTapGesture { selectedPerson = partner }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }

            if !children.isEmpty {
                connector
                HStack(spacing: 12) {
                    ForEach(children) { child in
                        if !child.isExChild || app.exesShown {
                            PersonCard(person: child)
                                .onTapGesture { selectedPerson = child }
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: app.exesShown)
    }

    private func ancestorGroup(label: String, people: [Person]) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.wine)
                .textCase(.uppercase)
            HStack(spacing: 8) {
                ForEach(people) { person in
                    PersonCard(person: person, compact: true)
                        .onTapGesture { selectedPerson = person }
                }
            }
        }
    }

    private var connector: some View {
        Rectangle()
            .fill(Theme.ink.opacity(0.22))
            .frame(width: 2, height: 22)
    }

    // MARK: - Export

    @MainActor
    private func renderImage() -> UIImage? {
        let content = treeCanvas
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
        do {
            try data.write(to: url)
            shareItem = TreeShareItem(url: url)
        } catch {}
    }

    private func exportPDF() {
        guard let image = renderImage() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("family-tree-\(Int(Date().timeIntervalSince1970)).pdf")
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        do {
            try pdfRenderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                image.draw(at: .zero)
            }
            shareItem = TreeShareItem(url: url)
        } catch {}
    }
}

private struct TreeSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct TreeShareItem: Identifiable {
    let id = UUID()
    let url: URL
}
