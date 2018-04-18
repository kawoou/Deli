//
//  Container.swift
//  Deli
//

import Foundation

protocol ContainerType {
    func get(_ key: TypeKey) throws -> AnyObject?
    func gets(_ key: TypeKey, prefix: Bool) throws -> [AnyObject]
    func get(withoutResolve key: TypeKey) throws -> AnyObject?
    func gets(withoutResolve key: TypeKey, prefix: Bool) throws -> [AnyObject]
    func register(_ key: TypeKey, component: ContainerComponent)
    func link(_ key: TypeKey, children: TypeKey)
    func reset()
}

final class Container: ContainerType {

    // MARK: - Public

    func get(_ key: TypeKey) throws -> AnyObject? {
        let component = mutex.sync {
            return map[key]
        }
        
        guard let safeComponent = component else {
            let childKey = TypeKey(type: key.type, qualifier: "")
            if let chain = chainMap[childKey]?.first(where: { $0.qualifier == key.qualifier }), let component = map[chain] {
                return resolve(component: component)
            }
            throw ContainerError.unregistered
        }
        return resolve(component: safeComponent)
    }
    func gets(_ key: TypeKey, prefix: Bool) throws -> [AnyObject] {
        let newKey = TypeKey(type: key.type, qualifier: "")
        let list = mutex.sync {
            return chainMap[newKey] ?? []
        }

        do {
            #if swift(>=4.1)
            return try list
                .filter {
                    guard !prefix else {
                        return $0.qualifier.hasPrefix(key.qualifier)
                    }
                    guard key.qualifier != "" else {
                        return true
                    }
                    return $0.qualifier == key.qualifier
                }
                .compactMap { try get($0) }
            #else
            return try list
                .filter {
                    guard !prefix else {
                        return $0.qualifier.hasPrefix(key.qualifier)
                    }
                    guard key.qualifier != "" else {
                        return true
                    }
                    return $0.qualifier == key.qualifier
                }
                .flatMap { try get($0) }
            #endif
        } catch {
            return []
        }
    }
    func get(withoutResolve key: TypeKey) throws -> AnyObject? {
        let component = mutex.sync {
            return map[key]
        }
        
        guard let safeComponent = component else {
            let childKey = TypeKey(type: key.type, qualifier: "")
            if let chain = chainMap[childKey]?.first(where: { $0.qualifier == key.qualifier }), let component = map[chain] {
                return resolveWithoutResolve(component: component)
            }
            throw ContainerError.unregistered
        }
        return resolveWithoutResolve(component: safeComponent)
    }
    func gets(withoutResolve key: TypeKey, prefix: Bool) throws -> [AnyObject] {
        let newKey = TypeKey(type: key.type, qualifier: "")
        let list = mutex.sync {
            return chainMap[newKey] ?? []
        }
        
        do {
            #if swift(>=4.1)
            return try list
                .filter {
                    guard !prefix else {
                        return $0.qualifier.hasPrefix(key.qualifier)
                    }
                    guard key.qualifier != "" else {
                        return true
                    }
                    return $0.qualifier == key.qualifier
                }
                .compactMap { try get(withoutResolve: $0) }
            #else
            return try list
                .filter {
                    guard !prefix else {
                        return $0.qualifier.hasPrefix(key.qualifier)
                    }
                    guard key.qualifier != "" else {
                        return true
                    }
                    return $0.qualifier == key.qualifier
                }
                .flatMap { try get(withoutResolve: $0) }
            #endif
        } catch {
            return []
        }
    }
    func register(_ key: TypeKey, component: ContainerComponent) {
        mutex.sync {
            map[key] = component
        }
    }
    func link(_ key: TypeKey, children: TypeKey) {
        mutex.sync {
            guard var list = chainMap[key] else {
                chainMap[key] = Set([children])
                return
            }
            list.insert(children)
            chainMap[key] = list
        }
    }
    func reset() {
        mutex.sync {
            chainMap = [:]
            map = [:]
        }
    }

    // MARK: - Private

    private let mutex = Mutex()

    private var chainMap = [TypeKey: Set<TypeKey>]()
    private var map = [TypeKey: ContainerComponent]()
    
    private func resolve(component: ContainerComponent) -> AnyObject {
        switch component.scope {
        case .singleton:
            if let instance = mutex.sync(execute: { component.cache }) {
                return instance
            }
            
            let instance = component.resolver()
            mutex.sync {
                component.cache = instance
            }
            return instance

        case .prototype:
            return component.resolver()
        }
    }
    private func resolveWithoutResolve(component: ContainerComponent) -> AnyObject? {
        switch component.scope {
        case .singleton:
            return mutex.sync(execute: { component.cache })
            
        case .prototype:
            return component.resolver()
        }
    }
}
