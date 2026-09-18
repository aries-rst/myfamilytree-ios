import SwiftUI

struct PeopleListView: View {
    @EnvironmentObject var app: AppState
    @State private var query = ""
    @State private var selected: SelectedPerson?

    private struct FlatEntry: Identifiable {
        var id: String { person.id }
        let nodeId: UUID
        let person: FamilyPerson
    }

    private var flattened: [FlatEntry] {
        var result: [FlatEntry] = []
        func walk(_ node: FamilyNode) {
            for person in node.people {
                result.append(FlatEntry(nodeId: node.id, person: person))
            }
            for child in node.children { walk(child) }
            for ancestorNode in node.ancestors.values { walk(ancestorNode) }
        }
        walk(app.root)
        return result
    }

    private var filtered: [FlatEntry] {
        guard !query.isEmpty else { return flattened }
        return flattened.filter { $0.person.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { entry in
                Button {
                    selected = SelectedPerson(nodeId: entry.nodeId, person: entry.person)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Theme.paper)
                            Text(entry.person.avatarInitials).font(.system(size: 12, weight: .bold))
                        }
                        .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.person.name.isEmpty ? (app.lang == .ru ? "Без имени" : "No name") : entry.person.name)
                                .font(.system(size: 15, weight: .semibold))
                            if !entry.person.years.isEmpty {
                                Text(entry.person.years).font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .foregroundStyle(Theme.ink)
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: app.t(.search))
            .navigationTitle(app.t(.peopleTitle))
        }
        .sheet(item: $selected) { sel in
            PersonDetailSheet(nodeId: sel.nodeId, person: sel.person)
        }
    }
}
