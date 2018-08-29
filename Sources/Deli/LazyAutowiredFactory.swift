//
//  LazyAutowiredFactory.swift
//  Deli
//

/// The AutowiredFactory protocol is registered automatically, and lazily load
/// the required dependencies from IoC container.
///
/// It requires a payload, so is registered as a `prototype` scope.
public protocol LazyAutowiredFactory: Factory {
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

    /// Associated type for payload.
    associatedtype _Payload: Payload

    /// Since autowiring by Type may lead to multiple candidates.
    /// The `qualifier` property is used to differentiate that.
    var qualifier: String? { get }

    /// Pre-generated initialize method for instantiating.
    ///
    /// A payload already existed when instantiate, so injected into
    /// the constructor.
    init(payload: _Payload)

    /// Pre-generated initialize method for 1 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1)

    /// Pre-generated initialize method for 2 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2)

    /// Pre-generated initialize method for 3 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3)

    /// Pre-generated initialize method for 4 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4)

    /// Pre-generated initialize method for 5 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5)

    /// Pre-generated initialize method for 6 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6)

    /// Pre-generated initialize method for 7 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7)

    /// Pre-generated initialize method for 8 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8)

    /// Pre-generated initialize method for 9 dependencies
    /// constructor inject.
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9)

}
public extension LazyAutowiredFactory {
    /// To supports type-inference of the compiler.
    public var payloadType: _Payload.Type { return _Payload.self }
    public var qualifier: String? { return nil }

    func inject(_ dep1: Dep1) {
        self.inject(dep1)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2) {
        self.inject(dep1, dep2)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3) {
        self.inject(dep1, dep2, dep3)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4) {
        self.inject(dep1, dep2, dep3, dep4)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5) {
        self.inject(dep1, dep2, dep3, dep4, dep5)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6) {
        self.inject(dep1, dep2, dep3, dep4, dep5, dep6)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7) {
        self.inject(dep1, dep2, dep3, dep4, dep5, dep6, dep7)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8) {
        self.inject(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8)
    }
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9) {
        self.inject(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, dep9)
    }
}
