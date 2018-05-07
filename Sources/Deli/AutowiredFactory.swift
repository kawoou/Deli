//
//  AutowiredFactory.swift
//  Deli
//

public protocol AutowiredFactory: Factory {
    associatedtype Dep1 = Void
    associatedtype Dep2 = Void
    associatedtype Dep3 = Void
    associatedtype Dep4 = Void
    associatedtype Dep5 = Void
    associatedtype Dep6 = Void
    associatedtype Dep7 = Void
    associatedtype Dep8 = Void
    associatedtype Dep9 = Void
    associatedtype _Payload: Payload

    var qualifier: String? { get }

    init(_ dep1: Dep1, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, payload: _Payload)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9, payload: _Payload)
}
public extension AutowiredFactory {
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
