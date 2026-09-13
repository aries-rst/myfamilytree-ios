import SwiftUI

@main
struct MyFamilyTreeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .tint(Theme.wine)
        }
    }
}
