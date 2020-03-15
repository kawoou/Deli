//
//  DependencyArray.swift
//  Deli
//
//  Created by Kawoou on 2020/03/06.
//

@propertyWrapper
public struct DependencyArray<Value>: Inject {

    // MARK: - Public property

    public var wrappedValue: [Value] { instance }

    // MARK: - Private property

    private let instance: [Value]

    // MARK: - Lifecycle

    public init() {
        instance = AppContext.shared.get([Value].self)
    }

    public init(
        qualifier: String? = nil,
        resolveRole: ResolveRole = .recursive
    ) {
        instance = AppContext.shared.get(
            [Value].self,
            qualifier: qualifier ?? "",
            resolveRole: resolveRole
        )
    }

    public init(
        qualifierBy: String,
        resolveRole: ResolveRole = .default
    ) {
        let qualifier = AppContext.shared.getProperty(qualifierBy) as! String
        self.init(qualifier: qualifier, resolveRole: resolveRole)
    }
}
