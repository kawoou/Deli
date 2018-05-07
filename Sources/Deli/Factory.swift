//
//  Factory.swift
//  Deli
//

public protocol Factory {
    associatedtype RawPayload: Payload
    
    var payloadType: RawPayload.Type { get }
}
