import ComposableArchitecture
import SharedKit
import StyleGuide
import SwiftUI

struct FormView: View {
    @Bindable var store: StoreOf<SignInFeature>

    var body: some View {
        VStack(spacing: Spacing.sp400) {
            Picker("", selection: $store.entryOption.animation()) {
                ForEach(SignInFeature.EntryOption.allCases, id: \.rawValue) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            
            switch store.entryOption {
            case .signUp:
                SignUpForm(store: store)
                    .animation(.easeIn, value: store.entryOption)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .signIn:
                SignInForm(store: store)
                    .animation(.easeIn, value: store.entryOption)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}
