import SwiftUI

public struct ZenixButton: View, Updateable {
    public enum State {
        case enabled, loading, disabled
    }
    
    private let action: () -> Void
    private let title: String
    
    private var state: State = .enabled
    
    public init(action: @escaping () -> Void, title: String) {
        self.action = action
        self.title = title
    }
    
    public var body: some View {
        Button(action: action, label: {
            Group {
                switch state {
                case .enabled, .disabled:
                    Text(title)
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sp300)
            .background(for: state)
            .foregroundStyle(Color.zenix.font.primary)
            .clipShape(RoundedRectangle(cornerRadius: Radius.r300))
        })
        .disabled(state != .enabled)
    }
    
    public func state(_ state: State) -> Self {
        update(\.state, value: state)
    }
}

// MARK: - Styling
private extension View {
    @ViewBuilder func background(for state: ZenixButton.State) -> some View {
        switch state {
        case .enabled, .loading:
            background(Color.accentColor)
        case .disabled:
            background(.gray)
        }
    }
}

#Preview {
    ZenixButton(action: {}, title: "Sign In")
        .state(.enabled)
        .frame(width: 350, height: 100)
        
}
