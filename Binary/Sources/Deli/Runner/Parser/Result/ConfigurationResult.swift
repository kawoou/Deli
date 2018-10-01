//
//  ConfigurationResult.swift
//  Deli
//

final class ConfigurationResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency]
    var imports: [String]

    var linkType: Set<String> = Set()

    init(_ instanceType: String) {
        self.instanceType = instanceType
        self.dependencies = []
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
            qualifier: "",
            scope: .singleton
        )\(linkString)
        """
    }
}
