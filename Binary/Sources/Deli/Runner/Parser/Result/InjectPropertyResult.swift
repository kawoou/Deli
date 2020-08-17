//
//  InjectPropertyResult.swift
//  Deli
//

final class InjectPropertyResult: Results {
    var valueType: Bool
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return false }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency] = []
    var inheritanceList: [String] = []
    var instanceDependency: [Dependency] = []
    
    var imports: [String] = []
    var module: String?

    var linkType: Set<String> = Set()

    let propertyKeys: [String]

    init(
        _ instanceType: String,
        propertyKeys: [String],
        valueType: Bool
    ) {
        self.instanceType = instanceType
        self.propertyKeys = propertyKeys
        self.valueType = valueType
    }
}
