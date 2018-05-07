//
//  Factory.swift
//  Deli
//

public protocol Factory: Inject {
    associatedtype RawPayload: Payload
    
    var payloadType: RawPayload.Type { get }
}
