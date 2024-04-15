import SwiftUI

public protocol Updateable {
    func update<V>(_ keyPath: WritableKeyPath<Self, V>, value: V) -> Self
}

public extension Updateable {
    func update<V>(_ keyPath: WritableKeyPath<Self, V>, value: V) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
