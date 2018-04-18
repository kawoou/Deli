//
//  ConfigFunctionResult.swift
//  Deli
//

final class ConfigFunctionResult: Results {
    var isLazy: Bool { return false }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()

    var parentInstanceType: String
    var variableName: String
    
    init(_ instanceType: String, _ scope: String?, _ qualifier: String?, _ dependency: [Dependency], parentInstanceType: String, variableName: String) {
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = dependency + [Dependency(name: parentInstanceType)]
        
        self.parentInstanceType = parentInstanceType
        self.variableName = variableName
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        return """
        context.register(
            \(instanceType).self,
            resolver: {
                let _\(parentInstanceType) = context.get(\(parentInstanceType).self, qualifier: "")!
                return _\(parentInstanceType).\(variableName)() as AnyObject
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}

