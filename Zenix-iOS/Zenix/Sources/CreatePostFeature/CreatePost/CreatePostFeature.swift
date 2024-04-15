import ComposableArchitecture
import Entities

@Reducer
public struct CreatePostFeature {
    public init() {}
    
    @Reducer
    public enum Destination {
        case camera(CameraFeature)
    }

    
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?

        public init() {}
    }
    
    public enum Action {
        case didTapCameraButton
        case destination(PresentationAction<Destination.Action>)

    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTapCameraButton:
                state.destination = .camera(.init())
                
            case .destination:
                break
            }
            
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
