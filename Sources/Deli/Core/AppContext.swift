//
//  AppContext.swift
//  Deli
//

import Foundation

/// The AppContext is the context that wrapped the container.
///
/// Most of them provide the same functionality as Containers, but they are
/// responsible for functions such as `Lazy` and `Factory`.
public class AppContext: AppContextType {
    
    // MARK: - Static

    /// Shared application context for using container.
    public static let shared: AppContextType = AppContext()
    
    /// Load dependency graph into the container.
    ///
    /// - Returns: Instance of shared application context.
    public static func load(_ moduleFactories: [ModuleFactory.Type]) -> AppContextType {
        let context = AppContext.shared as! AppContext
        
        moduleFactories
            .map { $0.init() }
            .forEach { $0.load(context: context) }
        
        context.container.load()
        return context
    }
    
    /// Reset dependency graph and container components.
    public static func reset() {
        let context = AppContext.shared as! AppContext
        
        for item in context.lazyDict.values {
            item.cancel()
        }
        context.lazyDict = [:]
        
        context.container.reset()
    }
    
    // MARK: - Property
    
    /// Test mode activate status
    public var isTestMode: Bool {
        return testQualifierPrefix != nil
    }

    // MARK: - Public
    
    /// Activate test mode
    ///
    /// When the test mode is activated, uses the qualifierPrefix in the
    /// `get()` and `gets()` methods.
    ///
    /// If `setTestMode(true, qualifierPrefix: "test")` has enabled test mode.
    /// When you call `get(Book.self, qualifier: "Novel")`, It works as below.
    ///
    /// - 1. gets(Book.self, qualifier: "testNovel")
    /// - 2. gets(Book.self, qualifier: "Novel")
    ///
    /// Returns an exists instance (`testNovel` is a high priority)
    ///
    /// - Parameters:
    ///     - active: Activate state
    ///     - qualifierPrefix: Qualifier prefix for test mode.
    public func setTestMode(_ active: Bool, qualifierPrefix: String) {
        testQualifierPrefix = active ? qualifierPrefix : nil
    }

    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instance, or nil.
    public func get<T>(_ type: T.Type, qualifier: String) -> T? {
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: type, qualifier: "\(testQualifierPrefix)\(qualifier)")
            if let testInstance = (try? container.get(testKey)) as? T {
                return testInstance
            }
        }
        
        let key = TypeKey(type: type, qualifier: qualifier)
        do {
            return try container.get(key) as? T
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
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: T.self, qualifier: "\(testQualifierPrefix)\(qualifier)")
            let prefixTest = qualifier.isEmpty
            
            let testList: [T] = {
                return (try? container.gets(testKey, prefix: prefixTest, payload: nil))?
                    .compactMap { $0 as? T } ?? []
            }()
            if testList.count > 0 {
                return testList
            }
        }
        
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            return try container.gets(key, prefix: false, payload: nil)
                .compactMap { $0 as? T }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return []
    }
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    /// - Returns: The resolved instance, or nil.
    public func get<T: Factory>(_ type: T.Type, qualifier: String, payload: T.RawPayload) -> T? {
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: type, qualifier: "\(testQualifierPrefix)\(qualifier)")
            if let testInstance = (try? container.get(testKey, payload: payload)) as? T {
                return testInstance
            }
        }
        
        let key = TypeKey(type: type, qualifier: qualifier)
        do {
            return try container.get(key, payload: payload) as? T
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
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: T.self, qualifier: "\(testQualifierPrefix)\(qualifier)")
            let prefixTest = qualifier.isEmpty
            
            let testList: [T] = {
                return (try? container.gets(testKey, prefix: prefixTest, payload: payload))?
                    .compactMap { $0 as? T } ?? []
            }()
            if testList.count > 0 {
                return testList
            }
        }
        
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            return try container.gets(key, prefix: false, payload: payload)
                .compactMap { $0 as? T }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return []
    }
    
    /// Get instance for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or nil.
    public func get<T>(withoutResolve type: T.Type, qualifier: String) -> T? {
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: type, qualifier: "\(testQualifierPrefix)\(qualifier)")
            if let testInstance = (try? container.get(withoutResolve: testKey)) as? T {
                return testInstance
            }
        }
        
        let key = TypeKey(type: type, qualifier: qualifier)
        do {
            return try container.get(withoutResolve: key) as? T
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
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: T.self, qualifier: "\(testQualifierPrefix)\(qualifier)")
            let prefixTest = qualifier.isEmpty
            
            let testList: [T] = {
                return (try? container.gets(withoutResolve: testKey, prefix: prefixTest))?
                    .compactMap { $0 as? T } ?? []
            }()
            if testList.count > 0 {
                return testList
            }
        }
        
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            return try container.gets(withoutResolve: key, prefix: false)
                .compactMap { $0 as? T }
        } catch let error {
            print("Deli Error: \(error)")
        }
        return []
    }

    /// Register in DI graph.
    ///
    /// By default, it is called from automatically generated code via
    /// Deli binary.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    /// - Returns: Returns a Linker for specifying the Type to allow access to
    ///   resolve the registered type.
    @discardableResult
    public func register<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        qualifier: String,
        scope: Scope
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
	    let component = DefaultContainerComponent(
    	    resolver: resolver,
    	    qualifier: qualifier,
    	    scope: scope
	    )
        container.register(key, component: component)

        return Linker(type, qualifier: qualifier)
    }

    /// Lazy register in DI graph.
    ///
    /// By default, it is called from automatically generated code via
    /// Deli binary.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - resolver: The closure to specify how to instantiate the instance.
    ///     - injector: The closure to specify how to inject with the
    ///       dependencies of the type.
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    /// - Returns: Returns a Linker for specifying the Type to allow access to
    ///   resolve the registered type.
    @discardableResult
    public func registerLazy<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        injector: @escaping (T) -> (),
        qualifier: String,
        scope: Scope
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
        let component = DefaultContainerComponent(
            resolver: { [unowned self] () -> AnyObject in
                let instance = resolver()

                let dispatchItem = DispatchWorkItem {
                    guard let instance = instance as? T else { return }
                    injector(instance)
                    
                    self.lazyDict.removeValue(forKey: key)
                }
                self.lazyDict[key] = dispatchItem
                self.lazyQueue.async(execute: dispatchItem)
                
                return instance as AnyObject
            },
            qualifier: qualifier,
            scope: scope
        )
        container.register(key, component: component)

        return Linker(type, qualifier: qualifier)
    }
    
    /// Register factory in DI graph.
    ///
    /// It is automatically managed as a prototype scope.
    /// By default, it is called from automatically generated code via
    /// Deli binary.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    ///     - qualifier: The qualifier.
    /// - Returns: Returns a Linker for specifying the Type to allow access to
    ///   resolve the registered type.
    @discardableResult
    public func registerFactory<T>(
        _ type: T.Type,
        resolver: @escaping FactoryResolver,
        qualifier: String
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
        let component = FactoryContainerComponent(
            resolver: resolver,
            qualifier: qualifier,
            scope: .prototype
        )
        container.register(key, component: component)
        
        return Linker(type, qualifier: qualifier)
    }
    
    /// Lazy register factory in DI graph.
    ///
    /// It is automatically managed as a prototype scope.
    /// By default, it is called from automatically generated code via
    /// Deli binary.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - resolver: The closure to specify how to instantiate the instance.
    ///     - injector: The closure to specify how to inject with the
    ///       dependencies of the type.
    ///     - qualifier: The qualifier.
    /// - Returns: Returns a Linker for specifying the Type to allow access to
    ///   resolve the registered type.
    @discardableResult
    public func registerLazyFactory<T>(
        _ type: T.Type,
        resolver: @escaping FactoryResolver,
        injector: @escaping (T) -> (),
        qualifier: String
    ) -> Linker<T> {
        let key = TypeKey(type: type, qualifier: qualifier)
        let component = FactoryContainerComponent(
            resolver: { [unowned self] (payload) -> AnyObject in
                let instance = resolver(payload)
                
                let dispatchItem = DispatchWorkItem {
                    guard let instance = instance as? T else { return }
                    injector(instance)
                    
                    self.lazyDict.removeValue(forKey: key)
                }
                self.lazyDict[key] = dispatchItem
                self.lazyQueue.async(execute: dispatchItem)
                
                return instance as AnyObject
            },
            qualifier: qualifier,
            scope: .prototype
        )
        container.register(key, component: component)
        
        return Linker(type, qualifier: qualifier)
    }

    // MARK: - Private

    private var mutex = Mutex()
    private var testQualifierPrefix: String?
    
    private var lazyDict = [TypeKey: DispatchWorkItem]()
    private var lazyQueue = DispatchQueue(label: "io.kawoou.deli.lazyQueue", target: DispatchQueue.main)
    
    let container: ContainerType

    // MARK: - Lifecycle

    private init() {
        testQualifierPrefix = nil
        
	    container = Container()
    }
}
