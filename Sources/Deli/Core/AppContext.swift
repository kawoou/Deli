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
    
    // MARK: - Public
    
    /// Load container components.
    ///
    /// - Parameters:
    ///     - factory: Container components.
    ///     - priority: Using priority.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public func load(_ factories: [ModuleFactory.Type], priority: LoadPriority = .normal) -> AppContext {
        for type in factories {
            load(type.init(), priority: priority)
        }
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
        lock.lock()
        defer { lock.unlock() }

        /// Duplicated load
        guard !loadedList.contains(where: { $0.factory === factory }) else { return self }

        factory.load(context: self)
        loadedList.append(
            LoadInfo(
                factory: factory,
                priority: priority
            )
        )
        loadedList.sort { (a, b) in
            guard a.priority.rawValue < b.priority.rawValue else { return true }
            return a.loadedAt < b.loadedAt
        }
        factory.container.load()
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
        instance.factory.reset()

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
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance, or nil.
    public func get<T: Factory>(
        _ type: T.Type,
        qualifier: String,
        payload: T.RawPayload,
        resolveRole: ResolveRule = .recursive
    ) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
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
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public func get<T: Factory>(
        _ type: [T].Type,
        qualifier: String,
        payload: T.RawPayload,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
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
    
    // MARK: - Lifecycle
    
    init() {}
}
