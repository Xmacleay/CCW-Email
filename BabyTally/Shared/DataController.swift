import Foundation
import SwiftData

/// Single source of truth for local storage. Deliberately local-only: no
/// CloudKit, no account, no network calls. The App Group container lets the
/// widget extension read the same store as the main app.
enum DataController {
    static let appGroupID = "group.com.babytally.shared"

    static let shared: ModelContainer = {
        let schema = Schema([
            Child.self,
            FeedEntry.self,
            DiaperEntry.self,
            SleepEntry.self,
            GrowthEntry.self,
        ])

        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("App Group container '\(appGroupID)' not found. Check entitlements on both targets.")
        }

        let storeURL = groupURL.appendingPathComponent("BabyTally.sqlite")
        let configuration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
