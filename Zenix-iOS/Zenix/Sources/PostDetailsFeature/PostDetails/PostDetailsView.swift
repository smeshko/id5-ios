import ComposableArchitecture
import Entities
import StyleGuide
import SwiftUI
import SharedKit
import SharedViews

public struct PostDetailsView: View {
    @Bindable var store: StoreOf<PostDetailsFeature>
    @State private var currentIndex = 0

    public init(store: StoreOf<PostDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        GeometryReader { geo in
            if let error = store.error {
                Text(error)
                    .foregroundStyle(.red)
                    .bold()
            }
            if let post = store.post {
                VStack(alignment: .leading) {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ZStack(alignment: .bottomTrailing) {
                                TabView(selection: $currentIndex) {
                                    ForEach(Array(store.imageIDs.enumerated()), id: \.1) { index, id in
                                        AsyncZenixImage(mediaID: id)
                                            .parentWidth(geo.size.width)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page)
                                
                                Text("\(currentIndex + 1)/\(store.imageIDs.count)")
                                    .padding()
                                    .font(.zenix.f2)
                                    .foregroundStyle(.white)
                            }
                            .frame(height: 395)
                            
                            Group {
                                Text(post.title)
                                    .font(.zenix.f4)
                                    .padding(.top, Spacing.sp300)
                                
                                Text(post.text)
                                    .font(.zenix.f3)
                                    .foregroundStyle(.gray)
                                    .padding(.top, Spacing.sp200)
                                
                                Text("Posted on \(post.createdAt.formatted(date: .numeric, time: .omitted))")
                                    .font(.zenix.f2)
                                    .foregroundStyle(.gray)
                                    .padding(.top, Spacing.sp300)

                                Divider()
                                    .padding(.top, Spacing.sp300)

                                if !store.comments.isEmpty {
                                    Text("\(store.comments.count) comments")
                                        .font(.zenix.f5)
                                        .padding(.top, Spacing.sp300)
                                    
                                    ForEach(store.comments, id: \.id) { comment in
                                        CommentView(comment: comment)
                                    }
                                    .padding(.top, Spacing.sp400)
                                }
                                
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .scrollIndicators(.hidden)
                    
                    Divider()
                    
                    if let bottomStore = store.scope(state: \.bottomBarState, action: \.bottomBarAction) {
                        PostBottomBarView(store: bottomStore)
                            .padding()
                    }
                }
                .toolbar {
                    if let navBarStore = store.scope(
                        state: \.navigationBarState,
                        action: \.navigationBarAction
                    ) {
                        ToolbarItem(placement: .topBarLeading) {
                            PostNavigationBarLeadingView(store: navBarStore)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            PostNavigationBarTrailingView(store: navBarStore)
                        }
                    }
                }
            }
        }
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct CommentView: View {
    let comment: Comment.List.Response
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sp200) {
            if let id = comment.user.avatar {
                AsyncZenixImage(mediaID: id, size: .small)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: Spacing.sp100) {
                Text(comment.user.fullName)
                    .font(.zenix.f5)
                    .foregroundStyle(.gray)
                
                Text(comment.text)
                    .font(.zenix.f5)

                Text(comment.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                    .font(.zenix.f2)
                    .foregroundStyle(Color.gray.opacity(0.7))
            }
        }
    }
}

#Preview {
    CommentView(
        comment: .init(
            id: .init(),
            createdAt: .now,
            text: "This is a comment",
            postID: .init(),
            user: .init(
                id: .init(),
                firstName: "Ivo",
                lastName: "Tsonev",
                email: ""
            )
        )
    )
}

#Preview {
    PostDetailsView(
        store: .init(
            initialState: .init(postId: .init()),
            reducer: PostDetailsFeature.init
        )
    )
}
