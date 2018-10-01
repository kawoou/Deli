//
//  AutowiredFactoryConstructorResult.swift
//  Deli
//

final class AutowiredFactoryConstructorResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return true }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]
    var imports: [String]
    
    var linkType: Set<String> = Set()
    
    var payload: Dependency
    var instanceDependency: [Dependency]
    
    init(_ instanceType: String, _ qualifier: String?, _ dependencies: [Dependency], payload: Dependency) {
        self.instanceType = instanceType
        self.scope = "prototype"
        self.qualifier = qualifier
        self.dependencies = dependencies
        self.instanceDependency = dependencies
        self.imports = []
        self.payload = payload
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
        registerFactory(
            \(instanceType).self,
            resolver: { payload in
                \(dependencyResolve)
                return \(instanceType)(\(dependencyInject)\(instanceDependency.count > 0 ? ", " : "")payload: payload as! \(payload.name))
            },
            qualifier: "\(qualifier ?? "")"
        )\(linkString)
        """
    }
}
