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
    public static func Inject<T: Factory>(_ type: T.Type, with argument: T.RawPayload.Tuple, qualifier: String? = nil) -> T {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(type, qualifier: qualifier ?? "", payload: payload)!
    }
    public static func Inject<T: Factory>(_ type: [T].Type, with argument: T.RawPayload.Tuple, qualifier: String? = nil) -> [T] {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(type, qualifier: qualifier ?? "", payload: payload)
    }
    
    public func Inject<T>(_ type: T.Type, qualifier: String? = nil) -> T {
        return AppContext.shared.get(type, qualifier: qualifier ?? "")!
    }
    public func Inject<T>(_ type: [T].Type, qualifier: String? = nil) -> [T] {
        return AppContext.shared.get(type, qualifier: qualifier ?? "")
    }
    public func Inject<T: Factory>(_ type: T.Type, with argument: T.RawPayload.Tuple, qualifier: String? = nil) -> T {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(type, qualifier: qualifier ?? "", payload: payload)!
    }
    public func Inject<T: Factory>(_ type: [T].Type, with argument: T.RawPayload.Tuple, qualifier: String? = nil) -> [T] {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(type, qualifier: qualifier ?? "", payload: payload)
    }
}
