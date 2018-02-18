//
//  Container.swift
//  Deli
//

import Foundation

protocol ContainerType {
    func get(_ key: TypeKey) throws -> AnyObject?
    func gets(_ key: TypeKey) throws -> [AnyObject]
    func register(_ key: TypeKey, component: ContainerComponent)
    func link(_ key: TypeKey, children: TypeKey)
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
    func gets(_ key: TypeKey) throws -> [AnyObject] {
        let list = mutex.sync {
            return chainMap[key] ?? []
        }

        do {
            #if swift(>=4.1)
            return try list.compactMap { try get($0) }
            #else
            return try list.flatMap { try get($0) }
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

    // MARK: - Private

    private let mutex = Mutex()

    private var chainMap = [TypeKey: Set<TypeKey>]()
    private var map = [TypeKey: ContainerComponent]()

    private func resolve(component: ContainerComponent) -> AnyObject {
        switch component.scope {
        case .singleton:
            if let instance = component.cache {
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
}
