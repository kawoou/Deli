//
//  ContainerComponent.swift
//  Deli
//

import Foundation

final class ContainerComponent {

    var cache: AnyObject?
    let resolver: Resolver

    let qualifier: String
    let scope: Scope

    init(resolver: @escaping Resolver, qualifier: String, scope: Scope) {
        self.cache = nil
	    self.resolver = resolver
	    self.qualifier = qualifier
	    self.scope = scope
    }
}
