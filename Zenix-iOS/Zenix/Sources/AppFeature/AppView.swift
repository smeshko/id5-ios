import ComposableArchitecture
import MainNavigationFeature
import StyleGuide
import SwiftUI

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        MainNavigationView(
            store: .init(
                initialState: .init(),
                reducer: MainNavigationFeature.init
            )
        )
        .onAppear {
            store.send(.onAppear)
        }
        .tint(.blue)
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
