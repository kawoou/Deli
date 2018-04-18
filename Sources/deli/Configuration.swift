//
//  Configuration.swift
//  Deli
//

public protocol Configuration {}
public extension Configuration {

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

    public static func Config<T, Dep1>(
        _ type: T.Type,
        _ dependency1: Dep1.Type,
        qualifier: String = "",
        scope: Scope = .singleton,
        resolver: @escaping (Dep1) -> T
    ) -> () -> T {
        return { () -> T in
            guard let instance = AppContext.shared.get(withoutResolve: T.self, qualifier: qualifier) else {
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                return resolver(dep1)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                return resolver(dep1, dep2)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                return resolver(dep1, dep2, dep3)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                let dep5 = AppContext.shared.get(Dep5.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4, dep5)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                let dep5 = AppContext.shared.get(Dep5.self, qualifier: "")!
                let dep6 = AppContext.shared.get(Dep6.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                let dep5 = AppContext.shared.get(Dep5.self, qualifier: "")!
                let dep6 = AppContext.shared.get(Dep6.self, qualifier: "")!
                let dep7 = AppContext.shared.get(Dep7.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                let dep5 = AppContext.shared.get(Dep5.self, qualifier: "")!
                let dep6 = AppContext.shared.get(Dep6.self, qualifier: "")!
                let dep7 = AppContext.shared.get(Dep7.self, qualifier: "")!
                let dep8 = AppContext.shared.get(Dep8.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8)
            }
            return instance
        }
    }

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
                let dep1 = AppContext.shared.get(Dep1.self, qualifier: "")!
                let dep2 = AppContext.shared.get(Dep2.self, qualifier: "")!
                let dep3 = AppContext.shared.get(Dep3.self, qualifier: "")!
                let dep4 = AppContext.shared.get(Dep4.self, qualifier: "")!
                let dep5 = AppContext.shared.get(Dep5.self, qualifier: "")!
                let dep6 = AppContext.shared.get(Dep6.self, qualifier: "")!
                let dep7 = AppContext.shared.get(Dep7.self, qualifier: "")!
                let dep8 = AppContext.shared.get(Dep8.self, qualifier: "")!
                let dep9 = AppContext.shared.get(Dep9.self, qualifier: "")!
                return resolver(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, dep9)
            }
            return instance
        }
    }

}
