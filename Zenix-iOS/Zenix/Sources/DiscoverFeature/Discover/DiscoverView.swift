import ComposableArchitecture
import PostDetailsFeature
import StyleGuide
import SwiftUI

public struct DiscoverView: View {
    @Bindable var store: StoreOf<DiscoverFeature>
        
    public init(store: StoreOf<DiscoverFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            ScrollView {
                if let error = store.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .bold()
                }
                ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
                    NavigationLink(state: DiscoverFeature.Path.State.postDetails(.init(postId: cardStore.post.id))) {
                        DiscoverCardView(store: cardStore)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CurrentLocationView(store: store)
                }
            }
//            .searchable(text: $query)
//            .searchSuggestions({
//                VStack(alignment: .leading) {
//                    HStack {
//                        ForEach(tokens, id: \.id) { token in
//                            Text(token.t)
//                                .searchCompletion(token.t)
//                                .padding(Spacing.sp200)
//                                .background(Color.gray.opacity(0.2))
//                                .foregroundStyle(.white)
//                                .clipShape(RoundedRectangle(cornerRadius: Radius.r200))
//                        }
//                    }
//                    ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
//                        NavigationLink(state: DiscoverFeature.Path.State.postDetails(.init(postId: cardStore.post.id))) {
//                            DiscoverCardView(store: cardStore)
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//            })
            .scrollIndicators(.hidden)
        } destination: { store in
            switch store.state {
            case .postDetails:
                if let store = store.scope(state: \.postDetails, action: \.postDetails) {
                    PostDetailsView(store: store)
                }
            }
        }
        .onAppear {
            store.send(.didAppear)
        }
    }
}

private struct CurrentLocationView: View {
    let store: StoreOf<DiscoverFeature>
    
    var body: some View {
        Button(action: {}, label: {
            Text("Drin 1, 9000 Varna")
                .frame(maxWidth: .infinity)
                .padding(Spacing.sp200)
                .background(Color.accentColor.opacity(0.5))
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.r200))
        })
    }
}

#Preview {
    DiscoverView(
        store: .init(
            initialState: .init(),
            reducer: DiscoverFeature.init
        )
    )
}
