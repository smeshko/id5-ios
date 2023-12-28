import ComposableArchitecture
import Entities

public struct AppFeature: Reducer {
    public static let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init
    )
    
    init() {}
    
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
