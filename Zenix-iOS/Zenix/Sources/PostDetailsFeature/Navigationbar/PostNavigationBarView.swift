import ComposableArchitecture
import SharedViews
import StyleGuide
import SwiftUI

struct PostNavigationBarLeadingView: View {
    @Bindable var store: StoreOf<PostNavigationBarFeature>
    
    init(store: StoreOf<PostNavigationBarFeature>) {
        self.store = store
    }
    
    var body: some View {
        Button {
            store.send(.didTapUser)
        } label: {
            HStack {
                if let id = store.post.user.avatar {
                    AsyncZenixImage(mediaID: id, size: .small)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading) {
                    Text(store.post.user.fullName)
                        .font(.zenix.f2)
                        .bold()
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct PostNavigationBarTrailingView: View {
    @Bindable var store: StoreOf<PostNavigationBarFeature>
    
    init(store: StoreOf<PostNavigationBarFeature>) {
        self.store = store
    }
    
    var body: some View {
        HStack {
            if !store.isOwnPost {
                Button(action: {
                    store.send(.didTapFollowButton)
                }) {
                    Text(store.isFollowing ? "Following" : "Follow")
                        .font(.zenix.f2)
                        .padding(.horizontal, Spacing.sp500)
                        .padding(.vertical, Spacing.sp200)
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.r200))
                }
            }
            
            Button(action: {
                
            }) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    PostNavigationBarTrailingView(
        store: .init(
            initialState: .init(post: .mock()),
            reducer: PostNavigationBarFeature.init
        )
    )
}

#Preview {
    PostNavigationBarLeadingView(
        store: .init(
            initialState: .init(post: .mock()),
            reducer: PostNavigationBarFeature.init
        )
    )
}
