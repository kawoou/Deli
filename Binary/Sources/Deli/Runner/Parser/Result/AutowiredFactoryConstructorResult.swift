//
//  AutowiredFactoryConstructorResult.swift
//  Deli
//

final class AutowiredFactoryConstructorResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    
    var linkType: Set<String> = Set()
    
    var payload: Dependency
    var instanceDependency: [Dependency]
    
    init(_ instanceType: String, _ qualifier: String?, _ dependencies: [Dependency], payload: Dependency) {
        self.instanceType = instanceType
        self.scope = "prototype"
        self.qualifier = qualifier
        self.dependencies = dependencies
        
        self.instanceDependency = dependencies
        self.payload = payload
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")
        
        let dependencyResolve = instanceDependency
            .map { dependency in
                switch dependency.type {
                case .single:
                    return "let _\(dependency.name) = context.get(\(dependency.name).self, qualifier: \"\")!"
                case .array:
                    return "let _\(dependency.name) = context.get([\(dependency.name)].self, qualifier: \"\")"
                }
            }
            .joined(separator: "\n        ")
        
        let dependencyInject = instanceDependency
            .map { dependency in
                return "\(dependency.qualifier == "" ? "" : "\(dependency.qualifier): ")_\(dependency.name)"
            }
            .joined(separator: ", ")
        
        return """
        context.registerFactory(
            \(instanceType).self,
            resolver: { payload in
                \(dependencyResolve)
                return \(instanceType)(\(dependencyInject), payload: payload as! \(payload.name))
            },
            qualifier: "\(qualifier ?? "")"
        )\(linkString)
        """
    }
}
