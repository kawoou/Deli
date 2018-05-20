//
//  AppContextType.swift
//  Deli
//

/// Support protocol for the `AppContext`.
public protocol AppContextType {
    /// Test mode activate status
    var isTestMode: Bool { get }
    
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
    func setTestMode(_ active: Bool, qualifierPrefix: String)
    
    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instance, or nil.
    func get<T>(_ type: T.Type, qualifier: String) -> T?
    
    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or empty.
    func get<T>(_ type: [T].Type, qualifier: String) -> [T]
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    /// - Returns: The resolved instance, or nil.
    func get<T: Factory>(_ type: T.Type, qualifier: String, payload: T.RawPayload) -> T?
    
    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - payload: User data for resolve.
    /// - Returns: The resolved instances, or emtpy.
    func get<T: Factory>(_ type: [T].Type, qualifier: String, payload: T.RawPayload) -> [T]
    
    /// Get instance for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or nil.
    func get<T>(withoutResolve type: T.Type, qualifier: String) -> T?
    
    /// Get instance list for type without resolve.
    /// It is used to avoid repetitive resolve if already registered.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    /// - Returns: The resolved instances, or empty.
    func get<T>(withoutResolve type: [T].Type, qualifier: String) -> [T]
    
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
    func register<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        qualifier: String,
        scope: Scope
    ) -> Linker<T>
    
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
    func registerLazy<T>(
        _ type: T.Type,
        resolver: @escaping Resolver,
        injector: @escaping (T) -> (),
        qualifier: String,
        scope: Scope
    ) -> Linker<T>
    
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
    func registerFactory<T>(
        _ type: T.Type,
        resolver: @escaping FactoryResolver,
        qualifier: String
    ) -> Linker<T>
    
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
    func registerLazyFactory<T>(
        _ type: T.Type,
        resolver: @escaping FactoryResolver,
        injector: @escaping (T) -> (),
        qualifier: String
    ) -> Linker<T>
}
