//
//  Linker.swift
//  Deli
//

/// Specifying the Type to allow access to resolve the registered type.
///
/// It is instantiated by AppContext and only accessible link() method
/// from the outside.
public final class Linker<T> {

    // MARK: - Private

    private let container: ContainerType
    private let typeKey: TypeKey

    // MARK: - Public

    /// Link the connected type.
    ///
    /// - Parameters:
    ///     - type: The access type.
    /// - Returns: This instance.
    @discardableResult
    public func link<U>(_ type: U.Type) -> Linker<T> {
        let parentKey = TypeKey(type: type, qualifier: "")
        container.link(parentKey, children: typeKey)
        return self
    }

    // MARK: - Lifecycle

    init(_ container: ContainerType, type: T.Type, qualifier: String) {
        self.container = container
        self.typeKey = TypeKey(type: type, qualifier: qualifier)
    }
}
