import ComposableArchitecture
import Entities
import SignInFeature
import StyleGuide
import SwiftUI

public struct MyProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    
    public init(store: StoreOf<MyProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            UserProfileView(store: store)
                .animation(.easeIn, value: store.userDetails)
                .transition(.opacity)
                .fullScreenCover(
                    item: $store.scope(
                        state: \.signInState,
                        action: \.signInAction
                    ),
                    content: SignInView.init(store:)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private struct UserProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    
    private struct ViewState: Equatable {
        var user: User.Detail.Response?
        
        init(state: MyProfileFeature.State) {
            user = state.userDetails
        }
    }

    var body: some View {
        if let user = store.userDetails {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 40) {
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .font(.title2)
                    
                    Text(user.email)
                        .font(.subheadline)
                    
                    Text(user.isEmailVerified ?
                         "Email is verified!" : "Email is NOT verified")
                    .font(.body)
                    
                    Button(action: {
                        store.send(.logoutButtonTapped)
                    }, label: {
                        Text("Logout")
                    })
                }
            }
            .navigationTitle("My Profile")
        } else {
            ZenixButton(action: {
                store.send(.signInButtonTapped)
            }, title: "Sign In")
        }
    }
}

#Preview {
    MyProfileView(
        store: .init(
            initialState: .init(),
            reducer: {
                MyProfileFeature()
            }
        )
    )
}
