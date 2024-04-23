import ComposableArchitecture
import SwiftUI

public struct LocationPickerView: View {
    @Bindable var store: StoreOf<LocationPickerFeature>
    
    public init(store: StoreOf<LocationPickerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, LocationPickerFeature")
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    LocationPickerView(
        store: .init(
            initialState: .init(),
            reducer: LocationPickerFeature.init
        )
    )
}
