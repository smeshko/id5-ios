import AuthenticationServices
import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct SignInView: View {
    @Bindable private var store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                if store.signInSuccessful {
                    VerificationMailView(store: store)
                        .animation(.easeIn, value: store.signInSuccessful)
                        .transition(.opacity)
                        .navigationTitle("Verify your email")
                } else {
                    VStack(alignment: .leading, spacing: Spacing.sp300) {
                        FormView(store: store)
                            .animation(.easeIn, value: store.signInSuccessful)
                            .transition(.opacity)
                            .navigationTitle(store.entryOption.title)
                            .toolbar {
                                ToolbarItem(placement: .destructiveAction) {
                                    Button(action: {
                                        store.send(.closeButtonTapped)
                                    }, label: {
                                        Image(systemName: "xmark")
                                    })
                                }
                            }
                        
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                            Text("or")
                            
                                Rectangle()
                                    .frame(height: 1)
                        }
                        
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                            print(request)
                        } onCompletion: { result in
                            store.send(.appleAuthResponseReceived(result))
                        }
                        .frame(height: 60)

                    }
                }
            }
            .padding()
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

extension SignInFeature.State {
    var submitButtonState: ZenixButton.State {
        if !isFormValid {
            return .disabled
        }
        if isLoading {
            return .loading
        }
        return .enabled
    }
}

#Preview {
    SignInView(
        store: .init(
            initialState: .init(entryOption: .signIn),
            reducer: SignInFeature.init
        )
    )
}
