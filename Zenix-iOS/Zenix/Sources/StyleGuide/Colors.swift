import SwiftUI

public extension Color {
    enum zenix {
        public static var primary = Color(.zenixPrimary)
        public static var background = Color(.zenixBackground)
        public static var divider = Color(.zenixDivider)
        public static var component = Color(.zenixPrimaryComponent)
        
        public enum font {
            public static var primary = Color(.zenixFontPrimary)
            public static var secondary = Color(.zenixFontSecondary)
            public static var tertiary = Color(.zenixFontTertiary)
        }
    }
}
