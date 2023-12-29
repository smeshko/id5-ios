import ComposableArchitecture
import SwiftUI

public struct DebugSettingsView: View {
    let store: StoreOf<DebugSettingsFeature>
    
    public init(store: StoreOf<DebugSettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Picker("Environment", selection: viewStore.$baseURL) {
                    ForEach(DebugSettingsFeature.BaseURL.allCases, id: \.rawValue) { url in
                        Text(url.name)
                            .tag(url)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationTitle("Debug Settings")
        }
    }
}

#Preview {
    DebugSettingsView(
        store: .init(
            initialState: .init(),
            reducer: DebugSettingsFeature.init
        )
    )
}
