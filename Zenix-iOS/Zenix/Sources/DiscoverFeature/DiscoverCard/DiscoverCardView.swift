import ComposableArchitecture
import Entities
import StyleGuide
import SwiftUI

public struct DiscoverCardView: View {
    @Bindable var store: StoreOf<DiscoverCardFeature>
    
    public init(store: StoreOf<DiscoverCardFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text(store.post.text)
            .border(.red)
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    DiscoverCardView(
        store: .init(
            initialState: .init(
                post: .init(
                    id: .init(),
                    text: "This is a post",
                    imageIDs: [],
                    videoIDs: [],
                    tags: []
                )
            ),
            reducer: DiscoverCardFeature.init
        )
    )
}
