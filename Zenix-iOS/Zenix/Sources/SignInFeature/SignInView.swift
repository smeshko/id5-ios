import SwiftUI
import ComposableArchitecture
import StyleGuide

public struct SignInView: View {
    let store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Picker("", selection: viewStore.$entryOption) {
                    ForEach(SignInFeature.EntryOption.allCases, id: \.rawValue) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
                
                switch viewStore.entryOption {
                case .signUp:
                    SignUpForm(store: store)
                case .signIn:
                    SignInForm(store: store)
                }
            }
        }
    }
}

private struct SignUpForm: View {
    let store: StoreOf<SignInFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Enter email", text: viewStore.$email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                Section {
                    SecureField("Enter password", text: viewStore.$password)
                    SecureField("Confirm password", text: viewStore.$confirmPassword)
                }
                
                Section {
                    Button(action: {
                        viewStore.send(.signUpButtonTapped)
                    }, label: {
                        Text("Submit")
                    })
                }
            }
        }
    }
}

private struct SignInForm: View {
    let store: StoreOf<SignInFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Enter email", text: viewStore.$email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                Section {
                    SecureField("Enter password", text: viewStore.$password)
                    Button(action: {
                        viewStore.send(.forgotPasswordButtonTapped)
                    }, label: {
                        Text("Forgot password")
                    })
                }
                
                Section {
                    Button(action: {
                        viewStore.send(.signInButtonTapped)
                    }, label: {
                        Text("Submit")
                    })
                }
            }
        }
    }
}

#Preview {
    SignInView(
        store: .init(
            initialState: .init(),
            reducer: SignInFeature.init
        )
    )
}
