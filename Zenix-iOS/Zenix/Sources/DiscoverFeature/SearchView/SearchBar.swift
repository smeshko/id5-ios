import SwiftUI
import StyleGuide

struct SearchBar: UIViewRepresentable, Updateable {
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
