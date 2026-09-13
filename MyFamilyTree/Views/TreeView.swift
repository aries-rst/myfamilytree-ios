import SwiftUI

struct TreeView: View {
    @EnvironmentObject var app: AppState

    @State private var zoom: CGFloat = 1.0
    @GestureState private var pinchDelta: CGFloat = 1.0
    @State private var selectedPerson: Person?
    @State private var showAddSheet = false
    @State private var showLimitSheet = false

    private var displayedZoom: CGFloat {
        min(1.4, max(0.6, zoom * pinchDelta))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView([.horizontal, .vertical]) {
                    treeCanvas
                        .scaleEffect(displayedZoom)
                        .padding(40)
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
            AddPersonSheet()
        }
        .sheet(isPresented: $showLimitSheet) {
            LimitPaywallSheet()
        }
    }

    private var treeCanvas: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 28) {
                ancestorGroup(label: "Родители — Азиз", pair: DemoFamily.ancestorsA)
                ancestorGroup(label: "Родители — Нилуфар", pair: DemoFamily.ancestorsN)
            }
            connector

            HStack(spacing: 10) {
                PersonCard(person: app.people.first(where: { $0.id == "p-aziz" }) ?? DemoFamily.aziz, emphasized: true)
                    .onTapGesture { selectedPerson = DemoFamily.aziz }
                Text("⚭").font(.system(size: 20)).foregroundStyle(Theme.gold)
                PersonCard(person: DemoFamily.nilufar, emphasized: true)
                    .onTapGesture { selectedPerson = DemoFamily.nilufar }
                if app.exesShown {
                    PersonCard(person: DemoFamily.gulnora, emphasized: true)
                        .overlay(alignment: .top) {
                            Text("бывшая супруга")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.female)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .offset(y: -9)
                        }
                        .onTapGesture { selectedPerson = DemoFamily.gulnora }
                        .transition(.scale.combined(with: .opacity))
                }
            }
            connector

            HStack(spacing: 12) {
                ForEach(DemoFamily.children) { child in
                    if !child.isExChild || app.exesShown {
                        PersonCard(person: child)
                            .onTapGesture { selectedPerson = child }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: app.exesShown)
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

    private var connector: some View {
        Rectangle()
            .fill(Theme.ink.opacity(0.22))
            .frame(width: 2, height: 22)
    }
}
