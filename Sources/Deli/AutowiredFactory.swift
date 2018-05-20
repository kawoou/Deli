//
//  AutowiredFactory.swift
//  Deli
//

/// The AutowiredFactory protocol is registered automatically, and load the
/// required dependencies from IoC container.
///
/// It requires a payload, so is registered as a `prototype` scope.
public protocol AutowiredFactory: Factory {
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

    /// Pre-generated initialize method for 1 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, payload: _Payload)
    /// Pre-generated initialize method for 2 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, payload: _Payload)
    /// Pre-generated initialize method for 3 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, payload: _Payload)
    /// Pre-generated initialize method for 4 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, payload: _Payload)
    /// Pre-generated initialize method for 5 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, payload: _Payload)
    /// Pre-generated initialize method for 6 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, payload: _Payload)
    /// Pre-generated initialize method for 7 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, payload: _Payload)
    /// Pre-generated initialize method for 8 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, payload: _Payload)
    /// Pre-generated initialize method for 9 dependencies and single payload
    /// constructor inject.
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9, payload: _Payload)
}
public extension AutowiredFactory {
    /// To supports type-inference of the compiler.
    public var payloadType: _Payload.Type { return _Payload.self }
    public var qualifier: String? { return nil }

    init(_ dep1: Dep1, payload: _Payload) {
        self.init(dep1, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, payload: _Payload) {
        self.init(dep1, dep2, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, payload: _Payload) {
        self.init(dep1, dep2, dep3, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, dep5, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, payload: payload)
    }
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9, payload: _Payload) {
        self.init(dep1, dep2, dep3, dep4, dep5, dep6, dep7, dep8, dep9, payload: payload)
    }
}
