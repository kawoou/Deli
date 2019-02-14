//
//  AutowiredConstructorResult.swift
//  Deli
//

final class AutowiredConstructorResult: Results {
    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var instanceDependency: [Dependency]
    var imports: [String]

    var linkType: Set<String> = Set()
    
    init(
        _ instanceType: String,
        scope: String?,
        qualifier: String?,
        dependencies: [Dependency],
        valueType: Bool
    ) {
        self.valueType = valueType
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = dependencies
        self.instanceDependency = dependencies
        self.imports = []
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        let dependencyResolve = instanceDependency
            .enumerated()
            .flatMap { (index, dependency) -> [String] in
                if let qualifierBy = dependency.qualifierBy {
                    switch dependency.type {
                    case .single:
                        return [
                            "let _qualifier\(index) = context.getProperty(\"\(qualifierBy)\", type: String.self)!",
                            "let _\(index) = context.get(\(dependency.name).self, qualifier: _qualifier\(index))!"
                        ]
                    case .array:
                        return [
                            "let _qualifier\(index) = context.getProperty(\"\(qualifierBy)\", type: String.self)!",
                            "let _\(index) = context.get([\(dependency.name)].self, qualifier: _qualifier\(index))"
                        ]
                    }
                } else {
                    switch dependency.type {
                    case .single:
                        return ["let _\(index) = context.get(\(dependency.name).self, qualifier: \"\(dependency.qualifier)\")!"]
                    case .array:
                        return ["let _\(index) = context.get([\(dependency.name)].self, qualifier: \"\(dependency.qualifier)\")"]
                    }
                }
            }
            .joined(separator: "\n        ")

        let dependencyInject = instanceDependency
            .enumerated()
            .map { (index, dependency) in
                if dependency.qualifierBy != nil {
                    return "_\(index)"
                } else {
                    return "\(dependency.qualifier == "" ? "" : "\(dependency.qualifier): ")_\(index)"
                }
            }
            .joined(separator: ", ")

        return """
        register(
            \(instanceType).self,
            resolver: {
                \(dependencyResolve)
                return \(instanceType)(\(dependencyInject))
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}
