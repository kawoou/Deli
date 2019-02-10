//
//  ResolveResult.swift
//  deli
//
//  Created by Kawoou on 07/02/2019.
//

final class ResolveResult: Results {
    var valueType: Bool
    var isLazy: Bool
    var isFactory: Bool
    var isRegister: Bool
    var isResolved: Bool = true
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var instanceDependency: [Dependency]
    var imports: [String]
    var linkType: Set<String>

    init(_ data: ResolveData.Dependency) {
        valueType = data.isValueType
        isLazy = data.isLazy
        isFactory = data.isFactory
        isRegister = true
        instanceType = data.type
        scope = "unknown"
        qualifier = data.qualifier
        dependencies = data.dependencies.map {
            Dependency(parent: data.type, target: nil, name: $0.type)
        }
        instanceDependency = dependencies
        imports = []
        linkType = Set(data.linkType)
    }
}
