import SwiftUI
import UIKit

struct TreeView: View {
    @EnvironmentObject var app: AppState

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedPerson: SelectedPerson?
    @State private var formMode: PersonFormMode?

    private var isRussian: Bool { app.lang == .ru }
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 2.5

    var body: some View {
        NavigationStack {
            GeometryReader { outer in
                ZStack {
                    FamilyBranchView(
                        node: app.root, isRoot: true,
                        onTapPerson: { person, nodeId in selectedPerson = SelectedPerson(nodeId: nodeId, person: person) },
                        onAddChild: { nodeId in formMode = .addChild(nodeId: nodeId) },
                        onAddSpouse: { nodeId in formMode = .addSpouse(nodeId: nodeId) },
                        onAddParent: { nodeId, personId in
                            let name = app.root.node(withId: nodeId)?.people.first(where: { $0.id == personId })?.name ?? ""
                            formMode = .addParent(nodeId: nodeId, personId: personId, personName: name)
                        },
                        exesShown: app.exesShown, isRussian: isRussian
                    )
                    .padding(40)
                    .fixedSize()
                    .scaleEffect(scale)
                    .offset(offset)
                }
                .frame(width: outer.size.width, height: outer.size.height)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(maxScale, max(minScale, lastScale * value))
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            offset = CGSize(width: lastOffset.width + value.translation.width,
                                             height: lastOffset.height + value.translation.height)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        scale = 1.0; lastScale = 1.0
                        offset = .zero; lastOffset = .zero
                    }
                }
            }
            .clipped()
            .background(Theme.paper.opacity(0.4))
            .navigationTitle(isRussian ? "Семейное древо" : "Family Tree")
            .toolbar {
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
        .sheet(item: $selectedPerson) { sel in
            PersonDetailSheet(nodeId: sel.nodeId, person: sel.person)
        }
        .sheet(item: $formMode) { mode in
            AddPersonSheet(mode: mode)
        }
        .sheet(isPresented: $app.showLimitSheet) {
            LimitPaywallSheet()
        }
    }
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
    let onAddParent: (UUID, String) -> Void
    let exesShown: Bool
    let isRussian: Bool
    var showControls: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            if isRoot, showControls {
                HStack(alignment: .bottom, spacing: 24) {
                    ForEach(node.people) { person in
                        ancestorSlot(for: person)
                    }
                }
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
                HStack(spacing: 10) {
                    Button { onAddChild(node.id) } label: {
                        Text(isRussian ? "+ ребёнок" : "+ child")
                            .font(.system(size: 11, weight: .bold))
                            .fixedSize()
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Theme.gold)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Button { onAddSpouse(node.id) } label: {
                        Text(isRussian ? "+ супруг(а)" : "+ spouse")
                            .font(.system(size: 11, weight: .bold))
                            .fixedSize()
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Theme.wine)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
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

    /// Renders, above one specific person in the top row, either their existing parent
    /// pair (with a way to complete it if only one parent has been added so far), or a
    /// "+ Parents of X" button to start one. Each person in the row gets their own slot.
    @ViewBuilder
    private func ancestorSlot(for person: FamilyPerson) -> some View {
        VStack(spacing: 8) {
            if let ancestorNode = node.ancestors[person.id] {
                HStack(spacing: 0) {
                    ForEach(Array(ancestorNode.people.enumerated()), id: \.element.id) { index, ancestor in
                        if index > 0 { Divider().frame(height: 28).padding(.horizontal, 4) }
                        personChip(ancestor, nodeId: ancestorNode.id)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                if showControls, ancestorNode.people.count < 2 {
                    Button { onAddSpouse(ancestorNode.id) } label: {
                        Text(isRussian ? "+ супруг(а)" : "+ spouse")
                            .font(.system(size: 10, weight: .bold))
                            .fixedSize()
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Theme.wine)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                connector
            } else if !person.name.isEmpty {
                Button { onAddParent(node.id, person.id) } label: {
                    Text((isRussian ? "+ Родители \"" : "+ Parents of \"") + person.name + "\"")
                        .font(.system(size: 11, weight: .bold))
                        .fixedSize()
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Theme.gold)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                connector
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
                .fixedSize()
            if !person.years.isEmpty {
                Text(person.years)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.ink.opacity(0.6))
                    .fixedSize()
            }
            if person.isEx {
                Text(isRussian ? "бывш." : "ex")
                    .font(.system(size: 8, weight: .bold))
                    .fixedSize()
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
