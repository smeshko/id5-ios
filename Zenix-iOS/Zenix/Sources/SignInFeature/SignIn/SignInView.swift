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
