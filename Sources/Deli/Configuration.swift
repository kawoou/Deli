//
//  Configuration.swift
//  Deli
//

/// The Configuration protocol makes the user can register Resolver.
public protocol Configuration {}
public extension Configuration {

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T>(
        _ type: T.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping () -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                return resolver()
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                return resolver(dep1)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                return resolver(dep1, dep2)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                return resolver(dep1, dep2, dep3)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                return resolver(dep1, dep2, dep3, dep4)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - dependency5: Required dependency 5
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4, Dep5>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        _ dependency5: Dep5.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4, Dep5) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                let dep5 = AppContext.shared.get(Dep5.self)!
                return resolver(dep1, dep2, dep3, dep4, dep5)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - dependency5: Required dependency 5
    ///     - dependency6: Required dependency 6
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4, Dep5, Dep6>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        _ dependency5: Dep5.Type,
        _ dependency6: Dep6.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4, Dep5, Dep6) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                let dep5 = AppContext.shared.get(Dep5.self)!
                let dep6 = AppContext.shared.get(Dep6.self)!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - dependency5: Required dependency 5
    ///     - dependency6: Required dependency 6
    ///     - dependency7: Required dependency 7
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        _ dependency5: Dep5.Type,
        _ dependency6: Dep6.Type,
        _ dependency7: Dep7.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                let dep5 = AppContext.shared.get(Dep5.self)!
                let dep6 = AppContext.shared.get(Dep6.self)!
                let dep7 = AppContext.shared.get(Dep7.self)!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - dependency5: Required dependency 5
    ///     - dependency6: Required dependency 6
    ///     - dependency7: Required dependency 7
    ///     - dependency8: Required dependency 8
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Dep8>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        _ dependency5: Dep5.Type,
        _ dependency6: Dep6.Type,
        _ dependency7: Dep7.Type,
        _ dependency8: Dep8.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Dep8) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                let dep5 = AppContext.shared.get(Dep5.self)!
                let dep6 = AppContext.shared.get(Dep6.self)!
                let dep7 = AppContext.shared.get(Dep7.self)!
                let dep8 = AppContext.shared.get(Dep8.self)!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8)
            }
            return instance
        }
    }

    /// Register custom Resolver by developers.
    ///
    /// - Parameters:
    ///     - type: The dependency type to resolve.
    ///     - dependency1: Required dependency 1
    ///     - dependency2: Required dependency 2
    ///     - dependency3: Required dependency 3
    ///     - dependency4: Required dependency 4
    ///     - dependency5: Required dependency 5
    ///     - dependency6: Required dependency 6
    ///     - dependency7: Required dependency 7
    ///     - dependency8: Required dependency 8
    ///     - dependency9: Required dependency 9
    ///     - qualifier: The qualifier.
    ///     - scope: It is specify the way that manages the lifecycle.
    ///       (default is .singleton)
    ///     - resolver: The closure to specify how to resolve with the
    ///       dependencies of the type.
    ///       It is invoked when needs to instantiate the instance.
    /// - Returns: The closure that resolve dependency type.
    public static func Config<T, Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Dep8, Dep9>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        _ dependency2: Dep2.Type,
        _ dependency3: Dep3.Type,
        _ dependency4: Dep4.Type,
        _ dependency5: Dep5.Type,
        _ dependency6: Dep6.Type,
        _ dependency7: Dep7.Type,
        _ dependency8: Dep8.Type,
        _ dependency9: Dep9.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Dep8, Dep9) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self)!
                let dep2 = AppContext.shared.get(Dep2.self)!
                let dep3 = AppContext.shared.get(Dep3.self)!
                let dep4 = AppContext.shared.get(Dep4.self)!
                let dep5 = AppContext.shared.get(Dep5.self)!
                let dep6 = AppContext.shared.get(Dep6.self)!
                let dep7 = AppContext.shared.get(Dep7.self)!
                let dep8 = AppContext.shared.get(Dep8.self)!
                let dep9 = AppContext.shared.get(Dep9.self)!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, dep9)
            }
            return instance
        }
    }

}
