//
//  ComponentResult.swift
//  Deli
//

final class ComponentResult: Results {
    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var instanceDependency: [Dependency]
    var inheritanceList: [String] = []
    var imports: [String]
    var module: String?

    var linkType: Set<String> = Set()
    
    init(
        _ instanceType: String,
        scope: String?,
        qualifier: String?,
        valueType: Bool
    ) {
        self.valueType = valueType
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = []
        self.instanceDependency = []
        self.imports = []
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        return """
        register(
            \(instanceType).self,
            resolver: {
                return \(instanceType)()
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}
