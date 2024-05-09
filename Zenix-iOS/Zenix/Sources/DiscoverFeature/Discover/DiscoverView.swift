import ComposableArchitecture
import PostDetailsFeature
import StyleGuide
import SwiftUI

public struct DiscoverView: View {
    @Bindable var store: StoreOf<DiscoverFeature>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(store: StoreOf<DiscoverFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(alignment: .leading, spacing: Spacing.sp500) {
                Divider()
                
                CategoriesView(store: store.scope(state: \.categoriesState, action: \.categoriesAction))

                ScrollView {
                    if let error = store.error {
                        Text(error)
                            .foregroundStyle(.red)
                            .bold()
                    }
                    HStack(alignment: .top, spacing: Spacing.sp200) {
                        LazyVStack(spacing: Spacing.sp200) {
                            ForEach(store.scope(state: \.leftColumn, action: \.cards)) { cardStore in
                                NavigationLink(state: DiscoverFeature.Path.State.postDetails(.init(postId: cardStore.post.id))) {
                                    DiscoverCardView(store: cardStore)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        LazyVStack(spacing: Spacing.sp200) {
                            ForEach(
                                Array(store.scope(state: \.rightColumn, action: \.cards).enumerated()), id: \.1
                            ) { index, cardStore in
                                NavigationLink(state: DiscoverFeature.Path.State.postDetails(.init(postId: cardStore.post.id))) {
                                    DiscoverCardView(store: cardStore, imageHeight: index == 0 ? 120 : 180)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .toolbar {
                    if !store.address.isEmpty {
                        ToolbarItem(placement: .topBarLeading) {
                            CurrentLocationView(store: store)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            store.send(.didTapSearchButton)
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                        })
                    }
                }
                .refreshable {
                    store.send(.fetchPostsAndUser)
                }
                .scrollIndicators(.hidden)
            }
        } destination: { store in
            switch store.state {
            case .postDetails:
                if let store = store.scope(state: \.postDetails, action: \.postDetails) {
                    PostDetailsView(store: store)
                }
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.search, action: \.searchAction),
            content: { searchStore in
                SearchView(store: searchStore)
            }
        )
        .background(Color.zenix.background)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private struct CurrentLocationView: View {
    let store: StoreOf<DiscoverFeature>
    
    var body: some View {
        Button(action: {}, label: {
            HStack {
                Text(store.address)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
            }
            .font(.zenix.f2)
            .frame(maxWidth: 190)
            .padding(Spacing.sp200)
            .background(.white)
            .foregroundStyle(.black)
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
