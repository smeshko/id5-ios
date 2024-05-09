import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct PostBottomBarView: View {
    enum Field: Int, CaseIterable {
        case comment
    }

    @Bindable var store: StoreOf<PostBottomBarFeature>
    @FocusState private var focusedField: Field?

    public init(store: StoreOf<PostBottomBarFeature>) {
        self.store = store
    }
    
    public var body: some View {
        HStack {
            if store.isSignedIn {
                TextField("type in...", text: $store.newComment)
                    .onSubmit {
                        store.send(.didCommitComment)
                    }
                    .padding(
                        EdgeInsets(
                            top: Spacing.sp200,
                            leading: Spacing.sp200,
                            bottom: Spacing.sp200,
                            trailing: Spacing.sp200
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(.black.opacity(0.1), lineWidth: 1)
                    }
                    .focused($focusedField, equals: .comment)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
            } else {
                Text("Sign in to comment")
                    .font(.zenix.f5)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            if focusedField == nil {
                Label("\(store.post.likes)", systemImage: "hand.thumbsup.fill")
                    .font(.zenix.f2)
                Label("\(store.commentCount)", systemImage: "text.bubble.fill")
                    .font(.zenix.f2)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    PostBottomBarView(
        store: .init(
            initialState: .init(post: .mock()),
            reducer: PostBottomBarFeature.init
        )
    )
}
