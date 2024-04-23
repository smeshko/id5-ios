import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct AddressConfirmationView: View {
    @Bindable var store: StoreOf<AddressConfirmationFeature>
    
    public init(store: StoreOf<AddressConfirmationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text(store.address)
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    AddressConfirmationView(
        store: .init(
            initialState: .init(placeId: "1"),
            reducer: AddressConfirmationFeature.init
        )
    )
}
