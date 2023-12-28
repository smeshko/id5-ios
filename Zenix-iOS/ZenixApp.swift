import SwiftUI
import AppFeature

@main
struct ZenixApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: AppFeature.store)
        }
    }
}
