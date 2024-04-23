import ComposableArchitecture
import Entities
import StyleGuide
import SwiftUI

public struct AddressPickerView: View {
    @Bindable var store: StoreOf<AddressPickerFeature>
    
    public init(store: StoreOf<AddressPickerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            List {
                ForEach(store.suggestions, id: \.id) { suggestion in
                    NavigationLink(state: AddressPickerFeature.Path.State.addressConfirmation(.init(placeId: suggestion.placeId))) {
                        VStack(alignment: .leading) {
                            Text(suggestion.mainText)
                                .bold()
                            Text(suggestion.secondaryText)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always))
            .autocorrectionDisabled(true)
            .navigationTitle("Choose your address")
        } destination: { store in
            if let store = store.scope(state: \.addressConfirmation, action: \.addressConfirmation) {
                AddressConfirmationView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AddressPickerView(
        store: .init(
            initialState: .init(suggestions: [
                .init(placeId: "1", mainText: "Drin 1", secondaryText: "Varna Bulgaria"),
                .init(placeId: "1", mainText: "Drin 2", secondaryText: "Ruse Bulgaria")
            ]),
            reducer: AddressPickerFeature.init
        )
    )
}
