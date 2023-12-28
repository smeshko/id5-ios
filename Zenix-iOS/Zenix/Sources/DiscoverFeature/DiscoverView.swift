import ComposableArchitecture
import SwiftUI

public struct DiscoverView: View {
    let store: StoreOf<DiscoverFeature>
    
    public init(store: StoreOf<DiscoverFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
//            ForEachStore(
//                store.scope(
//                    state: \.contests,
//                    action: /DiscoverFeature.Action.row
//                )) { store in
//                    <#code#>
//                }
            Text("Hello, DiscoverFeature")
                .onAppear {
                    viewStore.send(.didAppear)
                }
        }
    }
}

#Preview {
    DiscoverView(
        store: .init(
            initialState: .init(),
            reducer: DiscoverFeature.init
        )
    )
}

