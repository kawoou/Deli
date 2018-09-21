//
//  ModuleFactory.swift
//  Deli
//

import Foundation

/// The ModuleFactory protocol is a factory of that loads dependency graph.
///
/// The code that generates dependency graph should be written on
/// load() method.
open class ModuleFactory {
    
    // MARK: - Private
    
    private var lazyDict = [TypeKey: DispatchWorkItem]()
    private var lazyQueue = DispatchQueue(label: "io.kawoou.deli.lazyQueue", target: DispatchQueue.main)
    
    // MARK: - Internal
    
    let container: ContainerType
    
    // MARK: - Public
    
    /// Load the dependency graph on container.
    ///
    /// - Parameters:
    ///     - context: Instance of AppContext.
    open func load(context: AppContext) {}
    
    /// Reset container components.
    public func reset() {
        for item in lazyDict.values {
            item.cancel()
        }
        lazyDict = [:]
        
        container.reset()
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
        
        return Linker(container, type: type, qualifier: qualifier)
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
        
        return Linker(container, type: type, qualifier: qualifier)
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
        
        return Linker(container, type: type, qualifier: qualifier)
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
        
        return Linker(container, type: type, qualifier: qualifier)
    }
    
    // MARK: - Lifecycle
    
    /// Pre-generated initialize method for instantiating.
    public required init() {
        container = Container()
    }
}
