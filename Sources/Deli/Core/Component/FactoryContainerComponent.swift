//
//  FactoryContainerComponent.swift
//  Deli
//

import Foundation

final class FactoryContainerComponent: ContainerComponent {
    
    var cache: Any?
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
    func resolve() -> Any? {
        return nil
    }
    func resolve(payload: _Payload) -> Any? {
        return resolver(payload)
    }
}
