//
//  Autowired.swift
//  Deli
//

public protocol Autowired: Inject {
    associatedtype Dep1 = Void
    associatedtype Dep2 = Void
    associatedtype Dep3 = Void
    associatedtype Dep4 = Void
    associatedtype Dep5 = Void
    associatedtype Dep6 = Void
    associatedtype Dep7 = Void
    associatedtype Dep8 = Void
    associatedtype Dep9 = Void

    var scope: Scope { get }
    var qualifier: String? { get }

    init(_ dep1: Dep1)
    init(_ dep1: Dep1, _ dep2: Dep2)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8)
    init(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9)
}
public extension Autowired {
    public var scope: Scope { return .singleton }
    public var qualifier: String? { return nil }

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
