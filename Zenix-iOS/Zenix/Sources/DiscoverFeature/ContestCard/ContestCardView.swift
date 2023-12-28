import ComposableArchitecture
import SwiftUI

public struct ContestCardView: View {
    let store: StoreOf<ContestCardFeature>
    
    public init(store: StoreOf<ContestCardFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.contest.name)
        }
    }
}

#Preview {
    ContestCardView(
        store: .init(
            initialState: .init(contest: .init()),
            reducer: ContestCardFeature.init
        )
    )
}

