import ComposableArchitecture
import SwiftUI

public struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Form {
                    Section("Debug") {
                        NavigationLink(state: DebugSettingsFeature.State()) {
                            Text("Debug settings")
                        }
                    }
                }
                .navigationTitle("Settings")
            }
        } destination: { store in
            DebugSettingsView.init(store: store)
        }
    }
}

#Preview {
    SettingsView(
        store: .init(
            initialState: .init(),
            reducer: SettingsFeature.init
        )
    )
}
