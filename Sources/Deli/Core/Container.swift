//
//  Container.swift
//  Deli
//

import Foundation

protocol ContainerType {
    func get(_ key: TypeKey) throws -> AnyObject?
    func get(_ key: TypeKey, payload: _Payload) throws -> AnyObject?
    func gets(_ key: TypeKey, payload: _Payload?) throws -> [AnyObject]
    func get(withoutResolve key: TypeKey) throws -> AnyObject?
    func gets(withoutResolve key: TypeKey) throws -> [AnyObject]
    func register(_ key: TypeKey, component: _ContainerComponent)
    func link(_ key: TypeKey, children: TypeKey)
    func load()
    func unload()
    func reset()
}

final class Container: ContainerType {

    // MARK: - Public

    func get(_ key: TypeKey) throws -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }

        guard let safeComponent = map[key] else {
            let childKey = TypeKey(type: key.type)
            guard let chain = chainMap[childKey]?.first(where: { key.qualifier.isEmpty || $0.qualifier == key.qualifier }) else {
                throw ContainerError.unregistered
            }
            guard let component = map[chain] else {
                throw ContainerError.unregistered
            }
            return resolve(component: component)
        }
        return resolve(component: safeComponent)
    }
    func get(_ key: TypeKey, payload: _Payload) throws -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }

        guard let safeComponent = map[key] as? FactoryContainerComponent else {
            let childKey = TypeKey(type: key.type)
            guard let chain = chainMap[childKey]?.first(where: { key.qualifier.isEmpty || $0.qualifier == key.qualifier }) else {
                throw ContainerError.unregistered
            }
            guard let component = map[chain] as? FactoryContainerComponent else {
                throw ContainerError.unregistered
            }
            return resolveWithFactory(component: component, payload: payload)
        }
        return resolveWithFactory(component: safeComponent, payload: payload)
    }
    func gets(_ key: TypeKey) throws -> [AnyObject] {
        lock.lock()
        defer { lock.unlock() }

        let newKey = TypeKey(type: key.type)
        let list = chainMap[newKey] ?? []

        do {
            return try list
                .filter {
                    guard !key.qualifier.isEmpty else { return true }
                    return $0.qualifier == key.qualifier
                }
                .compactMap { try get($0) }
        } catch {
            return []
        }
    }
    func gets(_ key: TypeKey, payload: _Payload?) throws -> [AnyObject] {
        lock.lock()
        defer { lock.unlock() }

        let newKey = TypeKey(type: key.type)
        let list = (chainMap[newKey] ?? [])
            .filter {
                guard !key.qualifier.isEmpty else { return true }
                return $0.qualifier == key.qualifier
            }
        
        do {
            guard let payload = payload else {
                return try list.compactMap { try get($0) }
            }
            return try list.compactMap { try get($0, payload: payload) }
        } catch {
            return []
        }
    }
    func get(withoutResolve key: TypeKey) throws -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }

        guard let safeComponent = map[key] else {
            let childKey = TypeKey(type: key.type)
            if let chain = chainMap[childKey]?.first(where: { key.qualifier.isEmpty || $0.qualifier == key.qualifier }), let component = map[chain] {
                return resolveWithoutResolve(component: component)
            }
            throw ContainerError.unregistered
        }
        return resolveWithoutResolve(component: safeComponent)
    }
    func gets(withoutResolve key: TypeKey) throws -> [AnyObject] {
        lock.lock()
        defer { lock.unlock() }

        let newKey = TypeKey(type: key.type)
        let list = chainMap[newKey] ?? []
        
        do {
            return try list
                .filter {
                    guard !key.qualifier.isEmpty else { return true }
                    return $0.qualifier == key.qualifier
                }
                .compactMap { try get(withoutResolve: $0) }
        } catch {
            return []
        }
    }
    func register(_ key: TypeKey, component: _ContainerComponent) {
        lock.lock()
        defer { lock.unlock() }

        map[key] = component

        guard !key.qualifier.isEmpty else { return }
        let childKey = TypeKey(type: key.type)
        link(childKey, children: key)
    }
    func link(_ key: TypeKey, children: TypeKey) {
        lock.lock()
        defer { lock.unlock() }

        guard var list = chainMap[key] else {
            chainMap[key] = Set([children])
            return
        }
        list.insert(children)
        chainMap[key] = list
    }
    func load() {
        map.values
            .filter { $0.scope == .always }
            .forEach { [weak self] in
                _ = self?.resolve(component: $0)
            }
    }
    func unload() {
        lock.lock()
        defer { lock.unlock() }

        chainMap = [:]
        map = [:]
    }
    func reset() {
        lock.lock()
        defer { lock.unlock() }

        for (_, component) in map {
            component.cache = nil
            component.weakCache = nil
        }
    }

    // MARK: - Private

    private let lock = NSRecursiveLock()

    private var chainMap = [TypeKey: Set<TypeKey>]()
    private var map = [TypeKey: _ContainerComponent]()
    
    private func resolve(component: _ContainerComponent) -> AnyObject {
        lock.lock()
        defer { lock.unlock() }

        switch component.scope {
        case .always, .singleton:
            if let instance = component.cache {
                return instance
            }
            
            let instance = component.resolve()!
            component.cache = instance
            return instance

        case .prototype:
            return component.resolve()!
            
        case .weak:
            if let instance = component.weakCache {
                return instance
            }
            
            let instance = component.resolve()!
            component.weakCache = instance
            return instance
        }
    }
    private func resolveWithFactory(component: FactoryContainerComponent, payload: _Payload) -> AnyObject {
        return component.resolve(payload: payload)!
    }
    private func resolveWithoutResolve(component: _ContainerComponent) -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }

        switch component.scope {
        case .always, .singleton:
            return component.cache
            
        case .prototype:
            return component.resolve()!
            
        case .weak:
            return component.weakCache
        }
    }
}
