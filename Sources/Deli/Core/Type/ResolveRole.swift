//
//  ResolveRole.swift
//  Deli
//

@available(*, deprecated, renamed: "ResolveRole")
public typealias ResolveRule = ResolveRole

/// Resolve Role
///
/// `AppContext` can loaded many `ModuleFactory`.
/// When call Inject(), get instance by `LoadPriority` order by default.
public enum ResolveRole {
    
    // MARK: - Type
    
    /// Rule methods that you specify.
    ///
    /// - Parameters:
    ///     - factories: Sorted list of Factory in priority order.
    /// - Returns: Sorted list of Factory to be used.
    public typealias FindMethod = ([ModuleFactory]) -> [ModuleFactory]
    
    // MARK: - Case
    
    /// Get instance once with high priority order.
    case `default`
    
    /// Get instance all by high priority order.
    case recursive
    
    /// Other rule methods that you specify.
    case custom(FindMethod)
    
    // MARK: - Internal
    
    func findModules(_ factories: [ModuleFactory]) -> [ModuleFactory] {
        switch self {
        case .default:
            guard let factory = factories.first else { return [] }
            return [factory]
        case .recursive:
            return factories
        case .custom(let method):
            return method(factories)
        }
    }
}
