//
//  Autowired.swift
//  Deli
//

/// The `Autowired` protocol is registered automatically, and load the
/// required dependencies from IoC container.
public protocol Autowired: Inject {
    /// Associated type for dependency 1.
    associatedtype Dep1 = Void

    /// Associated type for dependency 2.
    associatedtype Dep2 = Void

    /// Associated type for dependency 3.
    associatedtype Dep3 = Void

    /// Associated type for dependency 4.
    associatedtype Dep4 = Void

    /// Associated type for dependency 5.
    associatedtype Dep5 = Void

    /// Associated type for dependency 6.
    associatedtype Dep6 = Void

    /// Associated type for dependency 7.
    associatedtype Dep7 = Void

    /// Associated type for dependency 8.
    associatedtype Dep8 = Void

    /// Associated type for dependency 9.
    associatedtype Dep9 = Void

    /// Since autowiring by Type may lead to multiple candidates.
    /// The `qualifier` property is used to differentiate that.
    var qualifier: String? { get }

    /// All instances lifecycle is managed by IoC Container.
    /// The `scope` property specifies how to manage it.
    var scope: Scope { get }

    /// Pre-generated initialize method for 1 dependencies constructor inject.
    init(_ dep1: Dep1)

    /// Pre-generated initialize method for 2 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2)

    /// Pre-generated initialize method for 3 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3)

    /// Pre-generated initialize method for 4 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4)

    /// Pre-generated initialize method for 5 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5)

    /// Pre-generated initialize method for 6 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6)

    /// Pre-generated initialize method for 7 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7)

    /// Pre-generated initialize method for 8 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8)

    /// Pre-generated initialize method for 9 dependencies constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9)

}
public extension Autowired {
    public var qualifier: String? { return nil }
    public var scope: Scope { return .singleton }

    init(_ dep1: Dep1) {
        self.init(dep1)
    }
    init(_ dep1: Dep1, _ dep2: Dep2) {
        self.init(dep1, dep2)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3) {
        self.init(dep1, dep2, dep3)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4) {
        self.init(dep1, dep2, dep3, dep4)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5) {
        self.init(dep1, dep2, dep3, dep4, dep5)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, dep9)
    }
}
