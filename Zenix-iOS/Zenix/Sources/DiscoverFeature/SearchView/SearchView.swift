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

private struct SearchBar: UIViewRepresentable, Updateable {
    let query: Binding<String>
    var onSubmit: () -> Void = {}
    
    init(query: Binding<String>) {
        self.query = query
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let view = UISearchBar()
        view.delegate = context.coordinator
        view.searchBarStyle = .minimal
        view.placeholder = "Search"

        return view
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = query.wrappedValue
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(query: query, onSubmit: onSubmit)
    }
    
    func onSubmit(_ callback: @escaping () -> Void) -> Self {
        update(\.onSubmit, value: callback)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let query: Binding<String>
        let onSubmit: () -> Void
        
        init(
            query: Binding<String>,
            onSubmit: @escaping () -> Void
        ) {
            self.query = query
            self.onSubmit = onSubmit
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            query.wrappedValue = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            onSubmit()
        }
    }
}
