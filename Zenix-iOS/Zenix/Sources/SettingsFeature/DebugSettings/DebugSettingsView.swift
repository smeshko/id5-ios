import ComposableArchitecture
import SwiftUI

public struct DebugSettingsView: View {
    @Bindable var store: StoreOf<DebugSettingsFeature>
    
    public var body: some View {
        Form {
            Picker("Environment", selection: $store.baseURL) {
                ForEach(DebugSettingsFeature.BaseURL.allCases, id: \.rawValue) { url in
                    Text(url.name)
                        .tag(url)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("Debug Settings")
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
