import ComposableArchitecture
import Entities
import StyleGuide
import SwiftUI

public struct PostDetailsView: View {
    @Bindable var store: StoreOf<PostDetailsFeature>
    
    public init(store: StoreOf<PostDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let error = store.error {
                Text(error)
                    .foregroundStyle(.red)
                    .bold()
            }
            if let post = store.post {
                ScrollView {
                    ZenixImage(media: store.images.first)
                    
                    Text(post.text)
                    ForEach(store.comments, id: \.id) { comment in
                        CommentView(comment: comment)
                    }
                    ZenixInputField("comment", text: $store.newComment)
                        .onSubmit {
                            store.send(.didCommitComment)
                        }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct CommentView: View {
    let comment: Comment.List.Response
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.user.fullName)
                    .font(.subheadline.bold())
                Spacer()
                Text(comment.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Color.gray.opacity(0.7))
            }
            Text(comment.text)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(Radius.r200)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.r200)
                .stroke(.black.opacity(0.2), lineWidth: 1)
        )
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

extension User.List.Response {
    var fullName: String {
        PersonNameComponents(
            givenName: firstName,
            familyName: lastName
        ).formatted()
    }
}
