//
//  Payload.swift
//  Deli
//

public protocol _Payload {}
public protocol Payload: _Payload {
    associatedtype Tuple = ()
    
    init(with argument: Tuple)
}
