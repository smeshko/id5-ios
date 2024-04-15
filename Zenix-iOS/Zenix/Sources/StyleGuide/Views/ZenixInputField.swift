import SwiftUI

public struct ZenixInputField: View, Updateable {
    public enum Style {
        case input, password
    }
    
    private let placeholder: String
    private let text: Binding<String>
    
    private var style: Style = .input
    private var contentType: UITextContentType = .emailAddress
    private var isAutocorrectEnabled: Bool = false
    
    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if style == .password {
                SecureField(placeholder, text: text)
                    .textContentType(contentType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

            } else {
                TextField(placeholder, text: text)
                    .textContentType(contentType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            Rectangle()
                .fill(.gray.opacity(0.5))
                .frame(height: 1)
        }
    }
    
    public func style(_ style: Style) -> Self {
        update(\.style, value: style)
    }
    
    public func textContentType(_ type: UITextContentType) -> Self {
        update(\.contentType, value: type)
    }
}

#Preview {
    ZenixInputField("enter email", text: .constant(""))
        .padding()
}
