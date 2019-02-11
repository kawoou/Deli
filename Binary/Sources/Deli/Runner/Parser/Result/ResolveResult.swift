//
//  ResolveResult.swift
//  deli
//
//  Created by Kawoou on 07/02/2019.
//

final class ResolveResult: Results {
    let valueType: Bool
    let isLazy: Bool
    let isFactory: Bool
    let isRegister: Bool
    let isResolved: Bool = true
    let instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var instanceDependency: [Dependency]
    var imports: [String]
    var linkType: Set<String>

    init(_ data: ResolveData.Dependency, imports: [String]) {
        self.valueType = data.isValueType
        self.isLazy = data.isLazy
        self.isFactory = data.isFactory
        self.isRegister = true
        self.instanceType = data.type
        self.scope = "unknown"
        self.qualifier = data.qualifier
        self.dependencies = data.dependencies.map {
            Dependency(parent: data.type, target: nil, name: $0.type)
        }
        self.instanceDependency = self.dependencies
        self.imports = imports
        self.linkType = Set(data.linkType)
    }
}
