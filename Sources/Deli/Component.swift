//
//  Component.swift
//  Deli
//

/// The class, struct, and protocol that inheritance `Component` protocol is
/// registered IoC Container automatically.
public protocol Component: Inject {
    /// Since autowiring by Type may lead to multiple candidates.
    /// The `qualifier` property is used to differentiate that.
    var qualifier: String? { get }
    
    /// All instances lifecycle is managed by IoC Container.
    /// The `scope` property specifies how to manage it.
    var scope: Scope { get }
}
public extension Component {
    public var qualifier: String? { return nil }
    public var scope: Scope { return .singleton }
}
