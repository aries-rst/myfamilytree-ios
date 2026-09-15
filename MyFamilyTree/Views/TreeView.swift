import SwiftUI

private struct TreeSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct TreeView: View {
    @EnvironmentObject var app: AppState

    @State private var zoom: CGFloat = 1.0
    @GestureState private var pinchDelta: CGFloat = 1.0
    @State private var selectedPerson: Person?
    @State private var showAddSheet = false
    @State private var showLimitSheet = false
    @State private var naturalSize: CGSize = .zero

    private var displayedZoom: CGFloat {
        min(1.4, max(0.6, zoom * pinchDelta))
    }

    private var isRussian: Bool { app.lang == .ru }

    private var ancestorsRoot: [Person] { app.people.filter { $0.role == .ancestorRoot } }
    private var ancestorsPartner: [Person] { app.people.filter { $0.role == .ancestorPartner } }
    private var rootPerson: Person? { app.people.first(where: { $0.role == .root }) }
    private var partners: [Person] { app.people.filter { $0.role == .rootPartner } }
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
                        .frame(
                            width: naturalSize.width * displayedZoom,
                            height: naturalSize.height * displayedZoom
                        )
                }
                .onPreferenceChange(TreeSizePreferenceKey.self) { size in
                    naturalSize = size
                }
                .background(Theme.paper.opacity(0.4))

                Button {
                    if app.canAddPerson {
                        showAddSheet = true
                    } else {
                        showLimitSheet = true
                    }
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
            .navigationTitle(app.t(.treeTitle))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(app.lang == .ru ? "RU" : "EN") {
                        app.lang = app.lang == .ru ? .en : .ru
                    }
                    .font(.system(size: 13, weight: .bold))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(app.t(.exes)) {
                        withAnimation { app.exesShown.toggle() }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .tint(Theme.wine)
                }
            }
            .sheet(item: $selectedPerson) { person in
                PersonDetailSheet(person: person)
            }
            .sheet(isPresented: $showAddSheet) {
                AddPersonSheet(mode: .add)
            }
            .sheet(isPresented: $showLimitSheet) {
                LimitPaywallSheet()
            }
        }
        .simultaneousGesture(
            MagnificationGesture()
                .updating($pinchDelta) { value, state, _ in state = value }
                .onEnded { value in zoom = min(1.4, max(0.6, zoom * value)) }
        )
    }

    private var treeCanvas: some View {
        VStack(spacing: 16) {
            if !ancestorsRoot.isEmpty || !ancestorsPartner.isEmpty {
                HStack(alignment: .top, spacing: 28) {
                    if !ancestorsRoot.isEmpty {
                        ancestorGroup(label: isRussian ? "МОИ РОДИТЕЛИ" : "MY PARENTS", pair: ancestorsRoot)
                    }
                    if !ancestorsPartner.isEmpty {
                        ancestorGroup(label: isRussian ? "РОДИТЕЛИ ПАРТНЁРА" : "PARTNER'S PARENTS", pair: ancestorsPartner)
                    }
                }
                connector
            }

            HStack(spacing: 10) {
                if let root = rootPerson {
                    PersonCard(person: root, emphasized: true)
                        .onTapGesture { selectedPerson = root }
                }
                ForEach(partners) { partner in
                    if !partner.isExSpouse || app.exesShown {
                        HStack(spacing: 10) {
                            Text("⚭").font(.system(size: 20)).foregroundStyle(Theme.gold)
                            PersonCard(person: partner, emphasized: true)
                                .overlay(alignment: .top) {
                                    if partner.isExSpouse {
                                        Text(isRussian ? "бывшая супруга" : "former spouse")
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

    private var connector: some View {
        Rectangle()
            .fill(Theme.ink.opacity(0.22))
            .frame(width: 2, height: 22)
    }

    private func ancestorGroup(label: String, pair: [Person]) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.wine)
                .textCase(.uppercase)
            HStack(spacing: 8) {
                ForEach(pair) { person in
                    PersonCard(person: person, compact: true)
                        .onTapGesture { selectedPerson = person }
                }
            }
        }
    }
}
