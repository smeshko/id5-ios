import ComposableArchitecture
import SharedKit
import StyleGuide
import SwiftUI

struct SignUpForm: View {
    enum Field: Int, CaseIterable {
        case firstName, lastName, email, password, confirmPassword
    }
    
    @FocusState private var focusedField: Field?
    @Bindable var store: StoreOf<SignInFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp400) {
            Section {
                ZenixInputField("Enter your first name (optional)", text: $store.firstName)
                    .textContentType(.givenName)
                    .focused($focusedField, equals: .firstName)
                
                ZenixInputField("Enter your last name (optional)", text: $store.lastName)
                    .textContentType(.familyName)
                    .focused($focusedField, equals: .lastName)
                
                ZenixInputField("Enter email", text: $store.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
            }
            Section {
                ZenixInputField("Enter password", text: $store.password)
                    .textContentType(.newPassword)
                    .style(.password)
                    .focused($focusedField, equals: .password)
                
                ZenixInputField("Confirm password", text: $store.confirmPassword)
                    .textContentType(.newPassword)
                    .style(.password)
                    .focused($focusedField, equals: .confirmPassword)
            }
            
            Section {
                ZenixButton(action: {
                    store.send(.signUpButtonTapped)
                }, title: "Submit")
                .state(store.submitButtonState)
            }
        }
        .fieldFocus($focusedField)
    }
}
