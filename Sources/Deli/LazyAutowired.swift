//
//  LazyAutowired.swift
//  Deli
//

public protocol LazyAutowired: Inject {
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

    init()

    func inject(_ dep1: Dep1)
    func inject(_ dep1: Dep1, _ dep2: Dep2)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8)
    func inject(_ dep1: Dep1, _ dep2: Dep2, _ dep3: Dep3, _ dep4: Dep4, _ dep5: Dep5, _ dep6: Dep6, _ dep7: Dep7, _ dep8: Dep8, _ dep9: Dep9)
}
public extension LazyAutowired {
    public var scope: Scope { return .singleton }
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
