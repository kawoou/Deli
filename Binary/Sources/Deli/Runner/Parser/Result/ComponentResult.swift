//
//  ComponentResult.swift
//  Deli
//

final class ComponentResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()
    
    init(_ instanceType: String, _ scope: String?, _ qualifier: String?) {
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = []
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
