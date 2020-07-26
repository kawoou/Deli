//
//  ResolveResult.swift
//  Deli
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
    var inheritanceList: [String]
    var imports: [String]
    var module: String?
    var linkType: Set<String>

    init(_ data: ResolveData.Dependency, imports: [String], module: String?) {
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
        self.inheritanceList = data.inheritanceType
        self.imports = data.imports + imports
        self.module = module
        self.linkType = Set(data.linkType)
    }
}
