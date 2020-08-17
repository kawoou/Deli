//
//  ConfigFunctionResult.swift
//  Deli
//

final class ConfigFunctionResult: Results {
    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var instanceDependency: [Dependency] = []
    var inheritanceList: [String] = []
    var imports: [String]
    var module: String?

    var linkType: Set<String> = Set()

    var parentInstanceType: String
    var variableName: String
    
    init(
        _ instanceType: String,
        scope: String?,
        qualifier: String?,
        dependencies: [Dependency],
        imports: [String],
        parentInstanceType: String,
        variableName: String,
        valueType: Bool
    ) {
        let parentDependency = Dependency(
            parent: instanceType,
            target: dependencies.first?.target,
            name: parentInstanceType
        )

        self.valueType = valueType
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = dependencies + [parentDependency]

        self.imports = imports

        self.parentInstanceType = parentInstanceType
        self.variableName = variableName
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        return """
        register(
            \(instanceType).self,
            resolver: {
                let parent = context.get(\(parentInstanceType).self, qualifier: "")!
                return parent.\(variableName)()
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}

