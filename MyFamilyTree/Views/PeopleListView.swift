import SwiftUI

struct PeopleListView: View {
    @EnvironmentObject var app: AppState
    @State private var query = ""
    @State private var selectedPerson: Person?

    private var filtered: [Person] {
        guard !query.isEmpty else { return app.people }
        return app.people.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { person in
                Button {
                    selectedPerson = person
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Theme.paper)
                            Text(person.avatarInitials).font(.system(size: 12, weight: .bold))
                        }
                        .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.system(size: 15, weight: .semibold))
                            Text(person.relation).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                }
                .foregroundStyle(Theme.ink)
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: app.t(.search))
            .navigationTitle(app.t(.peopleTitle))
        }
        .sheet(item: $selectedPerson) { person in
            PersonDetailSheet(person: person)
        }
    }
}
