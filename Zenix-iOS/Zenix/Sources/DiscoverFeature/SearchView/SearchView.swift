import ComposableArchitecture
import SharedKit
import StyleGuide
import SwiftUI

public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    @State var query: String = ""
        
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    SearchBar(query: $store.query)
                        .onSubmit {
                            store.send(.didSubmitSearch)
                        }
                        .padding(.horizontal, -8)
                    
                    Button(action: {
                        store.send(.didTapCancelButton)
                    }, label: {
                        Text("Cancel")
                    })
                }
                Text("Recent Searches")
                    .font(.zenix.f5)
                    .foregroundStyle(.black.opacity(0.5))
                
                ForEach(store.recentSearches, id: \.self) { text in
                    Text(text)
                        .font(.zenix.f5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding()
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    SearchView(
        store: .init(
            initialState: .init(),
            reducer: SearchFeature.init
        )
    )
}
