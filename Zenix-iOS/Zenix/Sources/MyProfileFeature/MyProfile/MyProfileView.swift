import ComposableArchitecture
import Entities
import SignInFeature
import StyleGuide
import SwiftUI

public struct MyProfileView: View {
    let store: StoreOf<MyProfileFeature>
    
    public init(store: StoreOf<MyProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            IfLetStore(
                store.scope(
                    state: \.signInState,
                    action: MyProfileFeature.Action.signInAction
                ),
                then: SignInView.init(store:), 
                else: {
                    if let user = viewStore.userDetails {
                        UserProfileView(user: user)
                    } else {
                        Text("Signed in")
                    }
                })
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct UserProfileView: View {
    let user: User.Account.Detail.Response

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 40) {
                Text(user.fullName)
                    .font(.title2)
                Text(user.email)
                    .font(.subheadline)
                
                Text(user.isEmailVerified ?
                     "Email is verified!" : "Email is NOT verified")
                .font(.body)
                
                Text("User level: \(user.level)")
                    .font(.body)
                
                Text(user.status.string)
                    .font(.body).bold()
            }
            .background(.green)
        }
        .background(.red)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private extension User.Account.Status {
    var string: String {
        switch self {
        case .notAccepting:
            "Not accepting challenges"
        case .openForChallenge:
            "Open for a challenge"
        }
    }
}

#Preview {
    MyProfileView(
        store: .init(
            initialState: .init(),
            reducer: MyProfileFeature.init
        )
    )
}
