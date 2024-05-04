import AccountClient
import ComposableArchitecture
import Endpoints
import Entities
import MediaClient
import PhotosUI
import PostClient
import SharedKit
import SignInFeature
import SwiftUI

@Reducer
public struct CreatePostFeature {
    public init() {}
    
    @Reducer
    public enum Destination {
        case camera(CameraFeature)
        case signIn(SignInFeature)
        case gallery
    }
    
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        
        var title: String = "This is a title"
        var text: String = "This is a post created from the iOS app!!"
        var selectedItems: [PhotosPickerItem] = []
        var selectedImages: [Image] = []
        var selectedImagesRequests: [Media.Upload.Request] = []
        var mediaIds: [UUID] = []

        public init() {}
    }
    
    public enum Action: BindableAction {
        case onAppear
        case didTapCreatePostButton
        case didTapCameraButton
        case destination(PresentationAction<Destination.Action>)
        
        case didLoadImages(([Image], [Media.Upload.Request]))
        case didUploadMedia([UUID])
        case didCreatePost(Result<Post.Create.Response, Error>)

        case binding(BindingAction<State>)
    }
    
    @Dependency (\.accountClient) var accountClient
    @Dependency (\.postClient) var postClient
    @Dependency (\.mediaClient) var mediaClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !accountClient.isSignedIn() {
                    state.destination = .signIn(.init())
                }
            
            case .didTapCreatePostButton:
                return .run { [state] send in
                    var storage: [UUID] = []
                    for imageData in state.selectedImagesRequests {
                        let response: Media.Upload.Response = try await mediaClient.upload(imageData)
                        storage.append(response.id)
                    }
                    
                    let request = Post.Create.Request.init(title: state.title, text: state.text, imageIDs: storage, videoIDs: [])
                    let response = try await postClient.create(request)
                    await send(.didCreatePost(.success(response)))
                } catch: { error, send in
                    await send(.didCreatePost(.failure(error)))
                }
                
            case .didTapCameraButton:
                state.destination = .camera(.init())
            
            case .binding(\.selectedItems):
                return .run { [state] send in
                    var storage: [Image] = []
                    var dataStorage: [Media.Upload.Request] = []
                    for item in state.selectedItems {
                        if let imageData = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: imageData) {
                                storage.append(Image(uiImage: uiImage))
                                let request = Media.Upload.Request(
                                    data: imageData,
                                    ext: item.ext ?? "jpeg",
                                    type: .photo
                                )
                                dataStorage.append(request)
                            }
                        }
                    }
                    
                    await send(.didLoadImages((storage, dataStorage)))
                }
                
            case .didCreatePost(.success(let response)):
                break
                
            case .didCreatePost(.failure(let error)):
                break
                
            case .didUploadMedia(let ids):
                state.mediaIds = ids
                
            case .didLoadImages(let images):
                state.selectedImages = images.0
                state.selectedImagesRequests = images.1
                
            case .destination, .binding:
                break
            }
            
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

private extension PhotosPickerItem {
    var ext: String? {
        supportedContentTypes.first?.tags[.filenameExtension]?.first
    }
}
