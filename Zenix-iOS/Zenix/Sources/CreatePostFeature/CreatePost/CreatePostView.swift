import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct CreatePostView: View {
    @Bindable var store: StoreOf<CreatePostFeature>
    
    @State private var takenPhotos: [UIImage] = []

    public init(store: StoreOf<CreatePostFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZenixButton(
            action: { store.send(.didTapCameraButton) },
            title: "Open Camera"
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
