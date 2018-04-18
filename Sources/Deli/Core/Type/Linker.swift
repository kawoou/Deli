//
//  Linker.swift
//  Deli
//

public protocol LinkerType {
    associatedtype T
    
    @discardableResult
    func link<U>(_ type: U.Type) -> Linker<T>
}

public final class Linker<T>: LinkerType {

    // MARK: - Private

    private let typeKey: TypeKey

    // MARK: - Public

    @discardableResult
    public func link<U>(_ type: U.Type) -> Linker<T> {
        let parentKey = TypeKey(type: type, qualifier: "")
        (AppContext.shared as? AppContext)?.container.link(parentKey, children: typeKey)
        return self
    }

    // MARK: - Lifecycle

    init(_ type: T.Type, qualifier: String) {
        typeKey = TypeKey(type: type, qualifier: qualifier)
    }
}
