import ComposableArchitecture
import DiscoverFeature
import MyProfileFeature
import SettingsFeature
import SwiftUI

public struct MainNavigationView: View {
    let store: StoreOf<MainNavigationFeature>
    
    public init(store: StoreOf<MainNavigationFeature>) {
        self.store = store
    }

    private struct ViewStore: Equatable {}
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView {
                NavigationStack {
                    DiscoverView(
                        store: .init(
                            initialState: .init(),
                            reducer: DiscoverFeature.init
                        )
                    )
                }
                .tag(MainNavigationFeature.Tab.discover)
                .tabItem {
                    Label("Discover", systemImage: "hand.wave.fill")
                }
                
                NavigationStack {
                    MyProfileView(
                        store: .init(
                            initialState: .init(),
                            reducer: MyProfileFeature.init
                        )
                    )
                }
                .tag(MainNavigationFeature.Tab.myProfile)
                .tabItem {
                    Label("My Profile", systemImage: "person")
                }
                
                SettingsView(
                    store: .init(
                        initialState: .init(),
                        reducer: SettingsFeature.init
                    )
                )
                .tag(MainNavigationFeature.Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
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

