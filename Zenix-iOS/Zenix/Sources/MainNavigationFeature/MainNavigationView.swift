import ComposableArchitecture
import CreatePostFeature
import DiscoverFeature
import MyProfileFeature
import SettingsFeature
import SwiftUI
import LocationPickerFeature

public struct MainNavigationView: View {
    @Bindable var store: StoreOf<MainNavigationFeature>
    
    public init(store: StoreOf<MainNavigationFeature>) {
        self.store = store
    }
    
    private struct ViewStore: Equatable {}
    
    public var body: some View {
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
            
            NavigationStack {
                AddressPickerView(
                    store: .init(
                        initialState: .init(),
                        reducer: AddressPickerFeature.init
                    )
                )
            }
            .tag(MainNavigationFeature.Tab.myProfile)
            .tabItem {
                Label("Location", systemImage: "person")
            }

            NavigationStack {
                CreatePostView(
                    store: .init(
                        initialState: .init(),
                        reducer: CreatePostFeature.init
                    )
                )
            }
            .tag(MainNavigationFeature.Tab.create)
            .tabItem {
                Label("Create Post", systemImage: "plus")
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

#Preview {
    MainNavigationView(
        store: .init(
            initialState: .init(),
            reducer: MainNavigationFeature.init
        )
    )
}

