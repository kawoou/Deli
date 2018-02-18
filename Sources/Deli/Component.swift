//
//  Component.swift
//  Deli
//

public protocol Component {
    var qualifier: String? { get }
    var scope: Scope { get }
}
public extension Component {
    public var qualifier: String? { return nil }
    public var scope: Scope { return .singleton }
}
