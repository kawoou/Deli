//
//  AppContext.swift
//  Deli
//

import Foundation

public protocol AppContextType {
    func get<T>(_ type: T.Type, qualifier: String) -> T?
    func get<T>(_ type: [T].Type, qualifier: String) -> [T]

    func register<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        qualifier: String,
        scope: Scope
    ) -> Linker<T>

    func registerLazy<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        injector: @escaping (T) -> (),
        qualifier: String,
        scope: Scope
    ) -> Linker<T>
}

public class AppContext: AppContextType {

    // MARK: - Static

    public static let shared: AppContextType = AppContext()

    // MARK: - Public

    public func get<T>(_ type: T.Type, qualifier: String) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        do {
            return try container.get(key) as? T
        } catch let error {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }

    public func get<T>(_ type: [T].Type, qualifier: String) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            #if swift(>=4.1)
            return try container.gets(key)
                .compactMap { $0 as? T }
            #else
            return try container.gets(key)
                .flatMap { $0 as? T }
            #endif
        } catch let error {
            assertionFailure(error.localizedDescription)
            return []
        }
    }

    @discardableResult
    public func register<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        qualifier: String,
        scope: Scope
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
	    let component = ContainerComponent(
    	    resolver: resolver,
    	    qualifier: qualifier,
    	    scope: scope
	    )
        container.register(key, component: component)

        return Linker(type, qualifier: qualifier)
    }

    @discardableResult
    public func registerLazy<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        injector: @escaping (T) -> (),
        qualifier: String,
        scope: Scope
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
        let component = ContainerComponent(
            resolver: { () -> AnyObject in
                let instance = resolver()

                DispatchQueue.main.async {
                    guard let instance = instance as? T else { return }
                    injector(instance)
                }
                
                return instance as AnyObject
            },
            qualifier: qualifier,
            scope: scope
        )
        container.register(key, component: component)

        return Linker(type, qualifier: qualifier)
    }

    // MARK: - Private

    let container: ContainerType

    // MARK: - Lifecycle

    private init() {
	    container = Container()
    }
}
