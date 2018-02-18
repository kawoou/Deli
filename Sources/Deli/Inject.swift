//
//  Inject.swift
//  Deli
//

import Foundation

public protocol Inject {}
public extension Inject {
    public static func Inject<T>(_ type: T.Type, qualifier: String? = nil) -> T {
        return AppContext.shared.get(type, qualifier: qualifier ?? "")!
    }
    public static func Inject<T>(_ type: [T].Type, qualifier: String? = nil) -> [T] {
        return AppContext.shared.get(type, qualifier: qualifier ?? "")
    }
}
