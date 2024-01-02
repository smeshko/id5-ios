import ComposableArchitecture
import MainNavigationFeature
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MainNavigationView(
                store: .init(
                    initialState: .init(),
                    reducer: MainNavigationFeature.init
                )
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

#Preview {
    AppView(
        store: .init(
            initialState: .init(),
            reducer: AppFeature.init
        )
    )
}
