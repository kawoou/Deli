//
//  AppContext.swift
//  Deli
//

import Foundation

public protocol AppContextType {
    /// Test mode activate status
    var isTestMode: Bool { get }
    
    /// Activate test mode
    ///
    /// When the test mode is activated, uses the qualifierPrefix in the `get()` and `gets()` methods.
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
    func setTestMode(_ active: Bool, qualifierPrefix: String)
    
    /// Get instance for type
    func get<T>(_ type: T.Type, qualifier: String) -> T?
    
    /// Get instance list for type
    func get<T>(_ type: [T].Type, qualifier: String) -> [T]
    
    /// Get instance for type without resolve
    func get<T>(withoutResolve type: T.Type, qualifier: String) -> T?
    
    /// Get instance list for type without resolve
    func get<T>(withoutResolve type: [T].Type, qualifier: String) -> [T]

    /// Register in DI graph
    @discardableResult
    func register<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        qualifier: String,
        scope: Scope
    ) -> Linker<T>

    /// Lazy register in DI graph
    @discardableResult
    func registerLazy<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        injector: @escaping (T) -> (),
        qualifier: String,
        scope: Scope
    ) -> Linker<T>
    
    /// Reset container
    func reset()
}

public class AppContext: AppContextType {
    
    // MARK: - Static

    public static let shared: AppContextType = AppContext()
    
    // MARK: - Property
    
    public var isTestMode: Bool {
        return testQualifierPrefix != nil
    }

    // MARK: - Public
    
    public func setTestMode(_ active: Bool, qualifierPrefix: String) {
        testQualifierPrefix = active ? qualifierPrefix : nil
    }

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

    public func get<T>(_ type: [T].Type, qualifier: String) -> [T] {
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: T.self, qualifier: "\(testQualifierPrefix)\(qualifier)")
            let prefixTest = (qualifier == "")
            
            let testList: [T] = {
                #if swift(>=4.1)
                return (try? container.gets(testKey, prefix: prefixTest))?
                    .compactMap { $0 as? T } ?? []
                #else
                return (try? container.gets(testKey, prefix: prefixTest))?
                    .flatMap { $0 as? T } ?? []
                #endif
            }()
            if testList.count > 0 {
                return testList
            }
        }
        
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            #if swift(>=4.1)
            return try container.gets(key, prefix: false)
                .compactMap { $0 as? T }
            #else
            return try container.gets(key)
                .flatMap { $0 as? T }
            #endif
        } catch let error {
            print("Deli Error: \(error)")
        }
        return []
    }
    
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
    
    public func get<T>(withoutResolve type: [T].Type, qualifier: String) -> [T] {
        if let testQualifierPrefix = testQualifierPrefix {
            let testKey = TypeKey(type: T.self, qualifier: "\(testQualifierPrefix)\(qualifier)")
            let prefixTest = (qualifier == "")
            
            let testList: [T] = {
                #if swift(>=4.1)
                return (try? container.gets(withoutResolve: testKey, prefix: prefixTest))?
                    .compactMap { $0 as? T } ?? []
                #else
                return (try? container.gets(withoutResolve: testKey, prefix: prefixTest))?
                    .flatMap { $0 as? T } ?? []
                #endif
            }()
            if testList.count > 0 {
                return testList
            }
        }
        
        let key = TypeKey(type: T.self, qualifier: qualifier)
        do {
            #if swift(>=4.1)
            return try container.gets(withoutResolve: key, prefix: false)
                .compactMap { $0 as? T }
            #else
            return try container.gets(withoutResolve: key)
                .flatMap { $0 as? T }
            #endif
        } catch let error {
            print("Deli Error: \(error)")
        }
        return []
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
    
    public func reset() {
        for item in lazyDict.values {
            item.cancel()
        }
        lazyDict = [:]
        
        self.container.reset()
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
