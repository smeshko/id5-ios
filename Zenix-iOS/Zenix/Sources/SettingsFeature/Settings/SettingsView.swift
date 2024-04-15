import ComposableArchitecture
import SwiftUI

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            Form {
                Section("Debug") {
                    NavigationLink(
                        "Debug settings",
                        state: SettingsFeature.Path.State.debugSettings(.init())
                    )
                }
            }
            .navigationTitle("Settings")

        } destination: { store in
            switch store.state {
            case .debugSettings:
                if let store = store.scope(state: \.debugSettings, action: \.debugSettings) {
                    DebugSettingsView(store: store)
                }
            }
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
