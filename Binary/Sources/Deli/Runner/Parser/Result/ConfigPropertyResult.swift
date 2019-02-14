//
//  ConfigPropertyResult.swift
//  Deli
//

final class ConfigPropertyResult: Results {
    struct PropertyInfo {
        let type: String
        let name: String
        let isOptional: Bool
    }

    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return true }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency] = []
    var instanceDependency: [Dependency] = []
    var imports: [String] = []

    var linkType: Set<String> = Set()

    let propertyTargetKey: String
    let propertyInfos: [PropertyInfo]

    init(
        _ instanceType: String,
        propertyTargetKey: String,
        propertyInfos: [PropertyInfo],
        valueType: Bool
    ) {
        self.valueType = valueType
        self.instanceType = instanceType
        self.propertyTargetKey = propertyTargetKey
        self.propertyInfos = propertyInfos
    }
    func makeSource() -> String? {
        let properties = propertyInfos.enumerated()
            .map { (index, key) in
                let unwrappingCharacter = (key.isOptional) ? "" : "!"
                let nextCharacter = (propertyInfos.count == index + 1) ? "" : ","
                return "\(key.name): context.getProperty(\"\(propertyTargetKey).\(key.name)\", type: \(key.type).self)\(unwrappingCharacter)\(nextCharacter)"
            }
            .joined(separator: "\n            ")

        return """
        register(
            \(instanceType).self,
            resolver: {
                return \(instanceType)(
                    \(properties)
                )
            },
            qualifier: "",
            scope: .prototype
        )
        """
    }
}
