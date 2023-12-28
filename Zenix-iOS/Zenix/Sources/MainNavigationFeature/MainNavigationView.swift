import ComposableArchitecture
import MyProfileFeature
import DiscoverFeature
import SwiftUI

public struct MainNavigationView: View {
    let store: StoreOf<MainNavigationFeature>
    
    public init(store: StoreOf<MainNavigationFeature>) {
        self.store = store
    }
    
    struct ViewState: Equatable, Hashable {
        var selectedTab: MainNavigationFeature.Tab
        
        init(state: MainNavigationFeature.State) {
            selectedTab = state.selectedTab
        }
    }
    
    private struct ViewStore: Equatable {}
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
//            TabView(selection: viewStore.binding(send: { .tabSelected($0.selectedTab) })) {
            TabView(selection: viewStore.binding(get: \.selectedTab, send: { .tabSelected($0) })) {
                DiscoverView(
                    store: .init(
                        initialState: .init(),
                        reducer: DiscoverFeature.init
                    )
                )
                .tag(MainNavigationFeature.Tab.discover)
                .tabItem {
                    Label("Discover", systemImage: "hand.wave.fill")
                }
                
                MyProfileView(
                    store: .init(
                        initialState: .init(),
                        reducer: MyProfileFeature.init
                    )
                )
                .tag(MainNavigationFeature.Tab.myProfile)
                .tabItem {
                    Label("My Profile", systemImage: "person")
                }
            }
        }
    }
}

#Preview {
    MainNavigationView(
        store: .init(
            initialState: .init(),
            reducer: MainNavigationFeature.init
        )
    )
}

