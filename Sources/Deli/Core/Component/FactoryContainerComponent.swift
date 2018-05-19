//
//  FactoryContainerComponent.swift
//  Deli
//

import Foundation

final class FactoryContainerComponent: ContainerComponent {
    
    var cache: AnyObject?
    weak var weakCache: AnyObject?
    let resolver: FactoryResolver
    
    let qualifier: String
    let scope: Scope
    
    init(resolver: @escaping FactoryResolver, qualifier: String, scope: Scope) {
        self.cache = nil
        self.weakCache = nil
        self.resolver = resolver
        self.qualifier = qualifier
        self.scope = scope
    }
    func resolve() -> AnyObject? {
        return nil
    }
    func resolve(payload: _Payload) -> AnyObject? {
        return resolver(payload)
    }
}
