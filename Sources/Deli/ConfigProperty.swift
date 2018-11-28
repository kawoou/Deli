//
//  ConfigProperty.swift
//  Deli
//
//  Created by Kawoou on 28/11/2018.
//

/// The `ConfigProperty` protocol is registered automatically, and load the
/// configuration properties from property files.
///
/// When injecting an object that inherits this protocol, it will always inject
/// the newly created object(like `Scope.prototype`).
/// Therefore, recommended implementing as struct-type.
///
/// For example, this `ServerConfig` struct injects data corresponding to the
/// "server" key of the property.
///
///     struct ServerConfig: ConfigProperty {
///         let target: String = "server"
///
///         let url: String
///     }
public protocol ConfigProperty {
    /// The target path to load from the configuration properties.
    var target: String { get }
}
