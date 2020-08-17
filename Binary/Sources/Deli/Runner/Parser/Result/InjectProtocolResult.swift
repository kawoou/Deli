//
//  InjectProtocolResult.swift
//  Deli
//

final class InjectProtocolResult: Results {
    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return false }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency]
    var instanceDependency: [Dependency]
    var inheritanceList: [String] = []
    var imports: [String]
    var module: String?

    var linkType: Set<String> = Set()

    init(
        _ instanceType: String,
        dependencies: [Dependency],
        valueType: Bool
    ) {
        self.valueType = valueType
        self.instanceType = instanceType
        self.dependencies = dependencies
        self.instanceDependency = []
        self.imports = []
    }
}
