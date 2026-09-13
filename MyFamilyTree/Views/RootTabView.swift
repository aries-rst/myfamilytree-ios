import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        TabView {
            TreeView()
                .tabItem { Label(app.t(.tabTree), systemImage: "person.3.fill") }

            PeopleListView()
                .tabItem { Label(app.t(.tabPeople), systemImage: "magnifyingglass") }

            ExportView()
                .tabItem { Label(app.t(.tabExport), systemImage: "square.and.arrow.up") }

            SettingsView()
                .tabItem { Label(app.t(.tabSettings), systemImage: "gearshape") }
        }
        .tint(Theme.wine)
    }
}
