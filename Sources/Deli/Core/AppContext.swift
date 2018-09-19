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
    
    private static let mutex = Mutex()
    
    /// Shared application context for using container.
    ///
    /// - Returns: Instance of shared application context.
    public static let shared = AppContext()
    
    /// Load container components.
    ///
    /// - Parameters:
    ///     - factory: Container components.
    ///     - priority: Using priority.
    /// - Returns: Instance of shared application context.
    public static func load(_ factories: [ModuleFactory.Type], priority: LoadPriority = .normal) -> AppContext {
        for type in factories {
            load(type.init(), priority: priority)
        }
        return AppContext.shared
    }
    
    /// Load container component.
    ///
    /// - Parameters:
    ///     - factory: Container component.
    ///     - priority: Using priority.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public static func load(_ factory: ModuleFactory, priority: LoadPriority = .normal) -> AppContext {
        let context = AppContext.shared
        
        return mutex.sync {
            /// Duplicated load
            guard !context.loadedList.contains(where: { $0.factory === factory }) else { return context }
            
            factory.load(context: context)
            context.loadedList.append(
                LoadInfo(
                    factory: factory,
                    priority: priority
                )
            )
            context.loadedList.sort { (a, b) in
                guard a.priority.rawValue >= b.priority.rawValue else { return false }
                return a.loadedAt < b.loadedAt
            }
            return context
        }
    }
    
    /// Unload container component.
    ///
    /// - Parameters:
    ///     - factory: Container component.
    /// - Returns: Instance of shared application context.
    @discardableResult
    public static func unload(_ factory: ModuleFactory) -> AppContext {
        let context = AppContext.shared
        
        return mutex.sync {
            guard let instance = context.loadedList.first(where: { $0.factory === factory }) else { return context }
            
            context.loadedList = context.loadedList.filter { $0.factory !== factory }
            instance.factory.reset()
            
            return context
        }
    }
    
    /// Unload all container components.
    public static func unloadAll() {
        let context = AppContext.shared
        context.loadedList
            .map { $0.factory }
            .forEach { unload($0) }
    }
    
    /// Reset container components.
    public static func reset() {
        let context = AppContext.shared
        context.loadedList
            .forEach { $0.factory.reset() }
    }
    
    // MARK: - Private
    
    private var loadedList: [LoadInfo] = []
    
    // MARK: - Public
    
    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instance, or nil.
    public func get<T>(_ type: T.Type, qualifier: String) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
        do {
            for info in loadedList {
                guard let instance = try info.factory.container.get(key) as? T else { continue }
                return instance
            }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return nil
    }
    
    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or empty.
    public func get<T>(_ type: [T].Type, qualifier: String) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
        return loadedList
            .flatMap { (try? $0.factory.container.gets(key, payload: nil)) ?? [] }
            .compactMap { $0 as? T }
    }
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    /// - Returns: The resolved instance, or nil.
    public func get<T: Factory>(_ type: T.Type, qualifier: String, payload: T.RawPayload) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
        do {
            for info in loadedList {
                guard let instance = try info.factory.container.get(key, payload: payload) as? T else { continue }
                return instance
            }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return nil
    }
    
    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    /// - Returns: The resolved instances, or emtpy.
    public func get<T: Factory>(_ type: [T].Type, qualifier: String, payload: T.RawPayload) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
        return loadedList
            .flatMap { (try? $0.factory.container.gets(key, payload: payload)) ?? [] }
            .compactMap { $0 as? T }
    }
    
    /// Get instance for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or nil.
    public func get<T>(withoutResolve type: T.Type, qualifier: String) -> T? {
        let key = TypeKey(type: type, qualifier: qualifier)
        
        do {
            for info in loadedList {
                guard let instance = try info.factory.container.get(withoutResolve: key) as? T else { continue }
                return instance
            }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return nil
    }
    
    /// Get instance list for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or empty.
    public func get<T>(withoutResolve type: [T].Type, qualifier: String) -> [T] {
        let key = TypeKey(type: T.self, qualifier: qualifier)
        
        return loadedList
            .flatMap { (try? $0.factory.container.gets(withoutResolve: key)) ?? [] }
            .compactMap { $0 as? T }
    }
    
    // MARK: - Lifecycle
    
    private init() {}
}
