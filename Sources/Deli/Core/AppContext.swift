//
//  AppContext.swift
//  Deli
//

import Foundation

/// The AppContext is the context that wrapped the container.
///
/// Most of them provide the same functionality as Containers, but they are
/// responsible for functions such as `Lazy` and `Factory`.
public class AppContext {
    
    // MARK: - Structure
    
    private struct LoadInfo {
        let factory: ModuleFactory
        let priority: LoadPriority
        let loadedAt: Date
        
        init(factory: ModuleFactory, priority: LoadPriority) {
            self.factory = factory
            self.priority = priority
            self.loadedAt = Date()
        }
    }
    
    // MARK: - Static
    
    /// Shared application context for using container.
    ///
    /// - Returns: Instance of shared application context.
    public static let shared = AppContext()
    
    // MARK: - Private
    
    private let lock = NSRecursiveLock()
    private var loadedList: [LoadInfo] = []

    private func getClassFromString(_ className: String) -> AnyClass? {
        if let classType = NSClassFromString(className) {
            return classType
        }
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            let newAppName = appName.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
            return NSClassFromString("\(newAppName).\(className)")
        }
        return nil
    }

    private func load(_ factories: [ModuleFactory], priority: LoadPriority) {
        lock.lock()
        defer { lock.unlock() }

        /// Duplicated load
        let factories = factories
            .filter { factory in
                !loadedList.contains(where: { $0.factory === factory })
            }

        /// Load factory
        factories.forEach { factory in
            factory.load(context: self)
            loadedList.append(
                LoadInfo(
                    factory: factory,
                    priority: priority
                )
            )
        }

        /// Update loaded list
        loadedList.sort { (a, b) in
            guard a.priority.rawValue < b.priority.rawValue else { return true }
            return a.loadedAt < b.loadedAt
        }

        /// Load container
        factories.forEach { $0.container.load() }
    }

    // MARK: - Public

    /// Get container components.
    ///
    /// - Parameters:
    ///     - type: Container component type.
    /// - Returns: Instance of container.
    public func getFactory<T>(_ type: T.Type) -> [T] {
        return loadedList.compactMap { $0.factory as? T }
    }

    /// Load container components.
    ///
    /// - Parameters:
    ///     - factory: Container components.
    ///     - priority: Using priority.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public func load(_ factories: [ModuleFactory.Type], priority: LoadPriority = .normal) -> AppContext {
        load(factories.map { $0.init() }, priority: priority)
        return self
    }
    
    /// Load container component.
    ///
    /// - Parameters:
    ///     - factory: Container component.
    ///     - priority: Using priority.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public func load(_ factory: ModuleFactory, priority: LoadPriority = .normal) -> AppContext {
        load([factory], priority: priority)
        return self
    }
    
    /// Unload container component.
    ///
    /// - Parameters:
    ///     - factory: Container component.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public func unload(_ factory: ModuleFactory) -> AppContext {
        lock.lock()
        defer { lock.unlock() }

        guard let instance = loadedList.first(where: { $0.factory === factory }) else { return self }

        #if swift(>=4.2)
        loadedList.removeAll { $0.factory === factory }
        #else
        loadedList = loadedList.filter { $0.factory !== factory }
        #endif
        instance.factory.unload()

        return self
    }
    
    /// Unload all container components.
    public func unloadAll() {
        loadedList
            .map { $0.factory }
            .forEach { unload($0) }
    }
    
    /// Reset container components.
    public func reset() {
        loadedList.forEach { $0.factory.reset() }
    }

    /// Get instance from string class.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - className: The dependency class name to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance, or nil.
    public func get<T>(
        _ type: T.Type,
        className: String,
        qualifier: String = "",
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        guard let classInfo = getClassFromString(className) else { return nil }
        let key = TypeKey(type: classInfo, qualifier: qualifier)

        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(key) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }

    /// Get instance from string class by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - className: The dependency class name to resolve.
    ///     - payload: User data for resolve.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance, or nil.
    public func get<T: Factory>(
        _ type: T.Type,
        className: String,
        payload: T.RawPayload,
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        guard let classInfo = getClassFromString(className) else { return nil }
        let key = TypeKey(type: classInfo, qualifier: "")

        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(key, payload: payload) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }

    /// Get instance from string class without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - className: The dependency class name to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instances, or nil.
    public func get<T>(
        withoutResolve type: T.Type,
        className: String,
        qualifier: String,
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        guard let classInfo = getClassFromString(className) else { return nil }
        let key = TypeKey(type: classInfo, qualifier: qualifier)

        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(withoutResolve: key) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }

    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance, or nil.
    public func get<T>(
        _ type: T.Type,
        qualifier: String = "",
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(key) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }
    
    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public func get<T>(
        _ type: [T].Type,
        qualifier: String = "",
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
        return resolveRole
            .findModules(loadedList.map { $0.factory })
            .flatMap { (try? $0.container.gets(key, payload: nil)) ?? [] }
            .compactMap { $0 as? T }
    }
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - payload: User data for resolve.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance, or nil.
    public func get<T: Factory>(
        _ type: T.Type,
        payload: T.RawPayload,
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        let key = TypeKey(type: type, qualifier: "")
        
        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(key, payload: payload) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }
    
    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - payload: User data for resolve.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public func get<T: Factory>(
        _ type: [T].Type,
        payload: T.RawPayload,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let key = TypeKey(type: T.self, qualifier: "")
        
        return resolveRole
            .findModules(loadedList.map { $0.factory })
            .flatMap { (try? $0.container.gets(key, payload: payload)) ?? [] }
            .compactMap { $0 as? T }
    }
    
    /// Get instance for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instances, or nil.
    public func get<T>(
        withoutResolve type: T.Type,
        qualifier: String,
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            guard let instance = try? factory.container.get(withoutResolve: key) else { continue }
            guard let result = instance as? T else { continue }
            return result
        }
        return nil
    }
    
    /// Get instance list for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public func get<T>(
        withoutResolve type: [T].Type,
        qualifier: String,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
        return resolveRole
            .findModules(loadedList.map { $0.factory })
            .flatMap { (try? $0.container.gets(withoutResolve: key)) ?? [] }
            .compactMap { $0 as? T }
    }

    /// Get property.
    ///
    /// - Parameters:
    ///     - path: Property path.
    ///     - resolveRole: The resolve role.
    /// - Returns: The property.
    public func getProperty(_ path: String, resolveRole: ResolveRule = .default) -> Any? {
        let list = resolveRole.findModules(loadedList.map { $0.factory })
        for factory in list {
            do {
                guard let property = try factory.container.getProperty(path) else { continue }
                return property
            } catch let error {
                print(error)
            }
        }
        return nil
    }
    
    // MARK: - Lifecycle
    
    init() {}
}
