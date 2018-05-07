//
//  ConfigurationResult.swift
//  Deli
//

final class ConfigurationResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()

    init(_ instanceType: String) {
        self.instanceType = instanceType
        self.dependencies = []
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        return """
        context.register(
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
