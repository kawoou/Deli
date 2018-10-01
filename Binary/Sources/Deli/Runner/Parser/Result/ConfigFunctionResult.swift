//
//  ConfigFunctionResult.swift
//  Deli
//

final class ConfigFunctionResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var imports: [String]

    var linkType: Set<String> = Set()

    var parentInstanceType: String
    var variableName: String
    
    init(_ instanceType: String, _ scope: String?, _ qualifier: String?, _ dependency: [Dependency], _ imports: [String], parentInstanceType: String, variableName: String) {
        let parentDependency = Dependency(
            parent: instanceType,
            target: dependency.first?.target,
            name: parentInstanceType
        )
        
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = dependency + [parentDependency]

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
                return parent.\(variableName)() as AnyObject
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}

