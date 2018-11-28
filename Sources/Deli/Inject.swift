//
//  Inject.swift
//  Deli
//

/// The Inject protocol is the supporter that injects the dependency type.
///
/// It is not registered in IoC conatiner, but is registered in Graph at
/// the time of build, and checks whether there is an invalid reference.
public protocol Inject {}
public extension Inject {
    
    // MARK: - Static
    
    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public static func Inject<T>(
        _ type: T.Type,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        return AppContext.shared.get(
            type,
            qualifier: qualifier ?? "",
            resolveRole: resolveRole
        )!
    }
    
    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public static func Inject<T>(
        _ type: [T].Type,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        return AppContext.shared.get(
            type,
            qualifier: qualifier ?? "",
            resolveRole: resolveRole
        )
    }
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public static func Inject<T: Factory>(
        _ type: T.Type,
        with argument: T.RawPayload.Tuple,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(
            type,
            qualifier: qualifier ?? "",
            payload: payload,
            resolveRole: resolveRole
        )!
    }

    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public static func Inject<T: Factory>(
        _ type: [T].Type,
        with argument: T.RawPayload.Tuple,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let payload = T.RawPayload(with: argument)
        return AppContext.shared.get(
            type,
            qualifier: qualifier ?? "",
            payload: payload,
            resolveRole: resolveRole
        )
    }

    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public static func Inject<T>(
        _ type: T.Type,
        qualifierBy: String,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public static func Inject<T>(
        _ type: [T].Type,
        qualifierBy: String,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public static func Inject<T: Factory>(
        _ type: T.Type,
        with argument: T.RawPayload.Tuple,
        qualifierBy: String,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, with: argument, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public static func Inject<T: Factory>(
        _ type: [T].Type,
        with argument: T.RawPayload.Tuple,
        qualifierBy: String,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, with: argument, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get property.
    ///
    /// - Parameters:
    ///     - path: Property path.
    ///     - resolveRole: The resolve role.
    /// - Returns: The property.
    public static func InjectProperty(
        _ path: String,
        resolveRole: ResolveRule = .default
    ) -> String {
        return AppContext.shared.getProperty(path, resolveRole: resolveRole) as! String
    }
    
    // MARK: - Public
    
    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public func Inject<T>(
        _ type: T.Type,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        return Self.Inject(
            type,
            qualifier: qualifier,
            resolveRole: resolveRole
        )
    }
    
    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public func Inject<T>(
        _ type: [T].Type,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        return Self.Inject(
            type,
            qualifier: qualifier,
            resolveRole: resolveRole
        )
    }
    
    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public func Inject<T: Factory>(
        _ type: T.Type,
        with argument: T.RawPayload.Tuple,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        return Self.Inject(
            type,
            with: argument,
            qualifier: qualifier,
            resolveRole: resolveRole
        )
    }
    
    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifier: The registered qualifier.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public func Inject<T: Factory>(
        _ type: [T].Type,
        with argument: T.RawPayload.Tuple,
        qualifier: String? = nil,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        return Self.Inject(
            type,
            with: argument,
            qualifier: qualifier,
            resolveRole: resolveRole
        )
    }

    /// Get instance for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public func Inject<T>(
        _ type: T.Type,
        qualifierBy: String,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance list for type.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or empty.
    public func Inject<T>(
        _ type: [T].Type,
        qualifierBy: String,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role(default: recursive)
    /// - Returns: The resolved instance.
    public func Inject<T: Factory>(
        _ type: T.Type,
        with argument: T.RawPayload.Tuple,
        qualifierBy: String,
        resolveRole: ResolveRule = .recursive
    ) -> T {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, with: argument, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get instance list for type by factory.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - argument: User data for resolve.
    ///     - qualifierBy: The registered qualifier by property.
    ///     - resolveRole: The resolve role.
    /// - Returns: The resolved instances, or emtpy.
    public func Inject<T: Factory>(
        _ type: [T].Type,
        with argument: T.RawPayload.Tuple,
        qualifierBy: String,
        resolveRole: ResolveRule = .default
    ) -> [T] {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        return Inject(type, with: argument, qualifier: qualifier, resolveRole: resolveRole)
    }

    /// Get property.
    ///
    /// - Parameters:
    ///     - path: Property path.
    ///     - resolveRole: The resolve role.
    /// - Returns: The property.
    public func InjectProperty(
        _ path: String,
        resolveRole: ResolveRule = .default
    ) -> String {
        return AppContext.shared.getProperty(path, resolveRole: resolveRole) as! String
    }
}
