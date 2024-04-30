import ComposableArchitecture
import PhotosUI
import SignInFeature
import StyleGuide
import SwiftUI

public struct CreatePostView: View {
    @Bindable var store: StoreOf<CreatePostFeature>

    public init(store: StoreOf<CreatePostFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading) {
                        ScrollView {
                            LazyHStack {
                                ForEach(0..<store.selectedImages.count, id: \.self) { i in
                                    store.selectedImages[i]
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                }
                            }
                        }
                        ZenixInputField("title", text: $store.title)
                        ZenixInputField("text", text: $store.text)
                    }
                }
                
                ZenixButton(action: {
                    store.send(.didTapCreatePostButton)
                }, title: "Create post")
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .toolbar {
            PhotosPicker("Select images", selection: $store.selectedItems, matching: .images)
        }
        .padding()
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.signIn,
                action: \.destination.signIn
            ),
            content: SignInView.init(store:)
        )
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.camera,
                action: \.destination.camera
            ),
            content: CameraView.init(store:)
        )
    }
}

#Preview {
    CreatePostView(
        store: .init(
            initialState: .init(),
            reducer: CreatePostFeature.init
        )
    )
}
