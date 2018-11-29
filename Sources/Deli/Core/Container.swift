//
//  Container.swift
//  Deli
//

import Foundation

protocol ContainerType {
    func get(_ key: TypeKey) throws -> Any?
    func get(_ key: TypeKey, payload: _Payload) throws -> Any?
    func gets(_ key: TypeKey, payload: _Payload?) throws -> [Any]
    func get(withoutResolve key: TypeKey) throws -> Any?
    func gets(withoutResolve key: TypeKey) throws -> [Any]
    func getProperty(_ path: String) throws -> Any?
    func loadProperty(_ properties: [String: Any])
    func register(_ key: TypeKey, component: _ContainerComponent)
    func link(_ key: TypeKey, children: TypeKey)
    func load()
    func unload()
    func reset()
}

final class Container: ContainerType {

    // MARK: - Public

    func get(_ key: TypeKey) throws -> Any? {
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
    func get(_ key: TypeKey, payload: _Payload) throws -> Any? {
        lock.lock()
        defer { lock.unlock() }

        guard let safeComponent = map[key] as? FactoryContainerComponent else {
            throw ContainerError.unregistered
        }
        return resolveWithFactory(component: safeComponent, payload: payload)
    }
    func gets(_ key: TypeKey, payload: _Payload?) throws -> [Any] {
        lock.lock()
        defer { lock.unlock() }

        let newKey = TypeKey(type: key.type)
        let list = (chainMap[newKey] ?? [])
            .filter { key.qualifier.isEmpty || $0.qualifier == key.qualifier }
        
        do {
            guard let payload = payload else {
                return try list.compactMap { try get($0) }
            }
            return try list.compactMap { try get($0, payload: payload) }
        } catch {
            return []
        }
    }
    func get(withoutResolve key: TypeKey) throws -> Any? {
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
    func gets(withoutResolve key: TypeKey) throws -> [Any] {
        lock.lock()
        defer { lock.unlock() }

        let newKey = TypeKey(type: key.type)
        let list = chainMap[newKey] ?? []
        
        do {
            return try list
                .filter { key.qualifier.isEmpty || $0.qualifier == key.qualifier }
                .compactMap { try get(withoutResolve: $0) }
        } catch {
            return []
        }
    }
    func getProperty(_ path: String) throws -> Any? {
        var target: Any = loadedProperty
        var key = ""
        var isStartBracket = false
        var isStartStringKey = false
        var isStringKey = false
        var stringStarter: Character = " "

        for character in path {
            switch character {
            case ".":
                guard !isStartStringKey else { throw ContainerError.notEndedColon }
                guard !isStartBracket else { throw ContainerError.notEndedBracket }
                guard !key.isEmpty else { continue }
                guard let oldTarget = target as? [String: Any] else { return nil }
                guard let newTarget = oldTarget[key] else { return nil }
                target = newTarget
                isStartBracket = false
                isStringKey = false
                key = ""

            case "\"", "\'":
                if isStartStringKey {
                    guard character == stringStarter else { throw ContainerError.notMatchedColon }
                    stringStarter = " "
                    isStartStringKey = false
                    isStringKey = true
                } else {
                    guard key.isEmpty else { throw ContainerError.notEmtpyKey }
                    stringStarter = character
                    isStartStringKey = true
                }

            case "[":
                if !key.isEmpty {
                    guard !isStartStringKey else { throw ContainerError.notEndedColon }
                    guard let oldTarget = target as? [String: Any] else { return nil }
                    guard let newTarget = oldTarget[key] else { return nil }
                    target = newTarget
                    isStartBracket = false
                    isStringKey = false
                    key = ""
                }
                guard !isStartBracket else { throw ContainerError.notEndedBracket }
                isStartBracket = true

            case "]":
                guard !isStartStringKey else { throw ContainerError.notEndedColon }
                guard isStartBracket else { throw ContainerError.notStartedBracket }
                if isStringKey {
                    guard let oldTarget = target as? [String: Any] else { return nil }
                    guard let newTarget = oldTarget[key] else { return nil }
                    target = newTarget
                } else if let index = Int(key) {
                    guard let oldTarget = target as? [Any] else { return nil }
                    guard index >= 0 else { return nil }
                    guard oldTarget.count > index else { return nil }
                    target = oldTarget[index]
                } else {
                    return nil
                }
                isStartBracket = false
                isStringKey = false
                key = ""

            default:
                key += String(character)
            }
        }
        if key.isEmpty {
            return target
        } else {
            guard !isStartStringKey else { throw ContainerError.notEndedColon }
            guard !isStartBracket else { throw ContainerError.notEndedBracket }
            guard let oldTarget = target as? [String: Any] else { return nil }
            return oldTarget[key]
        }
    }
    func loadProperty(_ properties: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }

        loadedProperty.merge(properties) { $1 }
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

    private var loadedProperty: [String: Any] = [:]

    private func resolve(component: _ContainerComponent) -> Any {
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
            component.weakCache = instance as AnyObject
            return instance
        }
    }
    private func resolveWithFactory(component: FactoryContainerComponent, payload: _Payload) -> Any {
        return component.resolve(payload: payload)!
    }
    private func resolveWithoutResolve(component: _ContainerComponent) -> Any? {
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
