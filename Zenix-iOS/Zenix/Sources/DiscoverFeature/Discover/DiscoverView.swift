import ComposableArchitecture
import SwiftUI

public struct DiscoverView: View {
    @Bindable var store: StoreOf<DiscoverFeature>
    
    public init(store: StoreOf<DiscoverFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, DiscoverFeature")
            .onAppear {
                store.send(.didAppear)
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
