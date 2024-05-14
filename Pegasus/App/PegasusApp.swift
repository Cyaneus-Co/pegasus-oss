import SwiftUI
import ComposableArchitecture
import NavigationStack

@main
struct PegasusApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(stack: NavigationStackCompat())
                .environmentObject(UserStore.shared)
        }
    }
}
