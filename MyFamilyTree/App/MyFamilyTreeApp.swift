import SwiftUI

@main
struct MyFamilyTreeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var store = StoreManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .environmentObject(store)
                .tint(Theme.wine)
                .task {
                    store.start(appState: appState)
                }
        }
    }
}
