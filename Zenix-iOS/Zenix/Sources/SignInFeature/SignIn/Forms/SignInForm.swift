import ComposableArchitecture
import SharedKit
import StyleGuide
import SwiftUI

struct SignInForm: View {
    enum Field: Int, CaseIterable {
        case email, password
    }
    
    @FocusState private var focusedField: Field?
    @Bindable var store: StoreOf<SignInFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp400) {
            Section {
                ZenixInputField("Enter email", text: $store.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
            }
            Section {
                ZenixInputField("Enter password", text: $store.password)
                    .textContentType(.password)
                    .style(.password)
                    .focused($focusedField, equals: .password)
                
                Button(action: {
                    store.send(.forgotPasswordButtonTapped)
                }, label: {
                    Text("Forgot password")
                })
            }
            
            Section {
                ZenixButton(action: {
                    store.send(.signInButtonTapped)
                }, title: "Submit")
                .state(store.submitButtonState)
            }
        }
        .fieldFocus($focusedField)
    }
}
