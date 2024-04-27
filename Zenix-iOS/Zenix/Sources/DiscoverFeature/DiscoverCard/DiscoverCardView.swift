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
        VStack(alignment: .leading) {
            ZenixImage(media: store.thumbnail)
            
            HStack {
                HStack(spacing: 0) {
                    Image(systemName: "text.bubble.fill")
                    Text("\(store.post.commentCount)")
                }
                .font(.caption)
                
                Spacer()
                
                Text(
                    store.post.createdAt
                        .formatted(.relative(presentation: .named, unitsStyle: .narrow))
                )
                .font(.caption)
            }
            Text(store.post.text)
                .onAppear {
                    store.send(.onAppear)
                }
        }
    }
}

#Preview {
    DiscoverCardView(
        store: .init(
            initialState: .init(
                post: .mock(createdAt: .now - 100000)
            ),
            reducer: DiscoverCardFeature.init
        )
    )
}
