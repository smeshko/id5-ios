import SwiftUI

struct FieldFocusView<Content: View, T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == Int {
    var focusedField: FocusState<T?>.Binding
    let content: Content
    
    init(focusedField: FocusState<T?>.Binding, @ViewBuilder content: () -> Content) {
        self.focusedField = focusedField
        self.content = content()
    }
    
    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        if T.allCases.count > 1 {
                            Button(action: previousFocus) {
                                Image(systemName: "chevron.up")
                            }
                            .disabled(!canSelectPreviousField)
                            
                            Button(action: nextFocus) {
                                Image(systemName: "chevron.down")
                            }
                            .disabled(!canSelectNextField)
                        }
                        Spacer()
                        Button("Done") {
                            focusedField.wrappedValue = nil
                        }
                    }
                }
            }
    }
    
    var canSelectPreviousField: Bool {
        if let currentFocus = focusedField.wrappedValue {
            return currentFocus.rawValue > 0
        } else {
            return false
        }
    }
    
    var canSelectNextField: Bool {
        if let currentFocus = focusedField.wrappedValue {
            return currentFocus.rawValue < T.allCases.count - 1
        } else {
            return false
        }
    }
    
    func previousFocus() {
        if canSelectPreviousField {
            selectPreviousField()
        }
    }
    
    func nextFocus() {
        if canSelectNextField {
            selectNextField()
        }
    }
    
    func selectPreviousField() {
        focusedField.wrappedValue = focusedField.wrappedValue.map {
            T(rawValue: $0.rawValue - 1)!
        }
    }
    
    func selectNextField() {
        focusedField.wrappedValue = focusedField.wrappedValue.map {
            T(rawValue: $0.rawValue + 1)!
        }
    }
}

struct FieldFocusViewModifier<T: Hashable & CaseIterable & RawRepresentable>: ViewModifier where T.RawValue == Int {
    var focusedField: FocusState<T?>.Binding
    
    func body(content: Content) -> some View {
        FieldFocusView(focusedField: focusedField) {
            content
        }
    }
}

public extension View {
    func fieldFocus<T: Hashable & CaseIterable & RawRepresentable>(_ field: FocusState<T?>.Binding) -> some View where T.RawValue == Int {
        modifier(FieldFocusViewModifier<T>(focusedField: field))
    }
}
