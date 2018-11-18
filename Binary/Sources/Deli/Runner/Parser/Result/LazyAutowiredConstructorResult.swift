//
//  LazyAutowiredConstructorResult.swift
//  Deli
//

final class LazyAutowiredConstructorResult: Results {
    var valueType: Bool
    var isLazy: Bool { return true }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var imports: [String]

    var linkType: Set<String> = Set()

    var instanceDependency: [Dependency]

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
            .map { (index, dependency) in
                switch dependency.type {
                case .single:
                    return "let _\(index) = context.get(\(dependency.name).self, qualifier: \"\(dependency.qualifier)\")!"
                case .array:
                    return "let _\(index) = context.get([\(dependency.name)].self, qualifier: \"\(dependency.qualifier)\")"
                }
            }
            .joined(separator: "\n        ")

        let dependencyInject = instanceDependency
            .enumerated()
            .map { (index, dependency) in
                return "\(dependency.qualifier == "" ? "" : "\(dependency.qualifier): ")_\(index)"
            }
            .joined(separator: ", ")

        return """
        registerLazy(
            \(instanceType).self,
            resolver: {
                return \(instanceType)()
            },
            injector: { instance in\(valueType ? "\n        var instance = instance" : "")
                \(dependencyResolve)
                instance.inject(\(dependencyInject))
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}

