//
//  PropertyValue.swift
//  Deli
//
//  Created by Kawoou on 2020/03/06.
//

@propertyWrapper
public struct PropertyValue {

    // MARK: - Public property

    public var wrappedValue: String { value }

    // MARK: - Private property

    private let value: String

    // MARK: - Lifecycle

    public init(
        _ path: String,
        resolveRole: ResolveRole = .default
    ) {
        value = AppContext.shared.getProperty(path, resolveRole: resolveRole) as! String
    }
}
