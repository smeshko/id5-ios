import ComposableArchitecture
import SwiftUI

public struct DebugSettingsView: View {
    @Bindable var store: StoreOf<DebugSettingsFeature>
    
    public var body: some View {
        Form {
            Section {
                Picker("Environment", selection: $store.baseURL) {
                    ForEach(DebugSettingsFeature.BaseURL.allCases, id: \.name) { url in
                        Text(url.name)
                            .tag(url)
                    }
                }
                if store.baseURL == .custom {
                    TextField("custom host", text: $store.customHost)
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
