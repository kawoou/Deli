//
//  Factory.swift
//  Deli
//

/// The Factory protocol supports type-inference of the compiler for
/// the payload.
public protocol Factory: Inject {
    /// Associated type for payload.
    associatedtype RawPayload: Payload
    
    /// To supports type-inference of the compiler.
    var payloadType: RawPayload.Type { get }
}
