//
//  Payload.swift
//  Deli
//

/// Internal access protocol.
public protocol _Payload {}

/// The Payload protocol is a set of user parameters.
///
/// This protocol inheritance to support type-inference of the compiler.
public protocol Payload: _Payload {
    /// Write tuple type.
    associatedtype Tuple = ()
    
    /// Map the tuple to the parameters.
    ///
    /// - Parameters:
    ///     - argument: Value of tuple type.
    init(with argument: Tuple)
}
