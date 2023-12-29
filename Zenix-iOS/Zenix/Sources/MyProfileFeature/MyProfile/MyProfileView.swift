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
            VStack {
                IfLetStore(
                    store.scope(
                        state: \.signInState,
                        action: MyProfileFeature.Action.signInAction
                    ),
                    then: SignInView.init(store:),
                    else: {
                        UserProfileView(store: store)
                            .animation(.easeIn, value: viewStore.userDetails)
                            .transition(.opacity)
                    })
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

private struct UserProfileView: View {
    let store: StoreOf<MyProfileFeature>
    
    private struct ViewState: Equatable {
        var user: User.Account.Detail.Response?
        
        init(state: MyProfileFeature.State) {
            user = state.userDetails
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            if let user = viewStore.user {
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
                        
                        Button(action: {
                            viewStore.send(.logoutButtonTapped)
                        }, label: {
                            Text("Logout")
                        })
                    }
                }
            }
        }
        .navigationTitle("My Profile")
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
