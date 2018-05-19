//
//  DefaultContainerComponent.swift
//  Deli
//

import Foundation

final class DefaultContainerComponent: ContainerComponent {
    
    var cache: AnyObject?
    weak var weakCache: AnyObject?
    let resolver: Resolver
    
    let qualifier: String
    let scope: Scope
    
    init(resolver: @escaping Resolver, qualifier: String, scope: Scope) {
        self.cache = nil
        self.weakCache = nil
        self.resolver = resolver
        self.qualifier = qualifier
        self.scope = scope
    }
    func resolve() -> AnyObject? {
        return resolver()
    }
}
