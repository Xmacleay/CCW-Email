import SwiftUI

@main
struct BabyTallyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(DataController.shared)
    }
}
