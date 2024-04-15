import ComposableArchitecture
import SwiftUI
import StyleGuide

public struct VerificationMailView: View {
    @Bindable private var store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .center) {
            Text("Please check your email for a verification link.")
                .font(.title)
            Spacer()
            ZenixButton(action: {
                store.send(.doneButtonTapped)
            }, title: "Go back to the app!")
        }
    }
}

#Preview {
    VerificationMailView(
        store: .init(
            initialState: .init(),
            reducer: SignInFeature.init
        )
    )
}
