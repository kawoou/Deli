//
//  Results.swift
//  Deli
//

protocol Results: class, CustomStringConvertible, CustomDebugStringConvertible {
    var valueType: Bool { get }
    var isLazy: Bool { get }
    var isFactory: Bool { get }
    var isRegister: Bool { get }
    var isResolved: Bool { get }
    var instanceType: String { get }
    var scope: String? { get set }
    var qualifier: String? { get set }
    var dependencies: [Dependency] { get set }
    var instanceDependency: [Dependency] { get set }
    var inheritanceList: [String] { get set }
    var imports: [String] { get set }
    var module: String? { get set }

    var linkType: Set<String> { get set }
    
    func makeSource() -> String?
}
extension Results {
    var isResolved: Bool { return false }
    
    func makeSource() -> String? {
        return nil
    }
    var description: String {
        let dependenciesString = dependencies
            .map {
                """
                \($0.name)(
                    type: \($0.type),
                    rule: \($0.rule),
                    qualifier: \"\($0.qualifier)\",
                    qualifierBy: \"\($0.qualifierBy ?? "")\"
                )
                """
            }
            .joined(separator: ",\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        let instanceDependenciesString = instanceDependency
            .map {
                """
                \($0.name)(
                    type: \($0.type),
                    rule: \($0.rule),
                    qualifier: \"\($0.qualifier)\",
                    qualifierBy: \"\($0.qualifierBy ?? "")\"
                )
                """
            }
            .joined(separator: ",\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        let inheritanceListString = inheritanceList
            .joined(separator: ",\n        ")

        let importsString = imports
            .joined(separator: ",\n        ")
        
        let linkTypeString = linkType
            .joined(separator: ",\n        ")
        
        return """
        \(instanceType)(
            valueType: \(valueType),
            isLazy: \(isLazy),
            isFactory: \(isFactory),
            isRegister: \(isRegister),
            isResolved \(isResolved),
            scope: \(scope ?? ".singleton"),
            qualifier: \"\(qualifier ?? "")\",
            dependencies: [\(dependenciesString.isEmpty ? "" : ("\n        " + dependenciesString + "\n    "))],
            instanceDependency: [\(instanceDependenciesString.isEmpty ? "" : ("\n        " + instanceDependenciesString + "\n    "))],
            inheritanceList: [\(inheritanceListString.isEmpty ? "" : ("\n        " + inheritanceListString + "\n    "))],
            imports: [\(importsString.isEmpty ? "" : ("\n        " + importsString + "\n    "))],
            linkType: [\(linkTypeString.isEmpty ? "" : ("\n        " + linkTypeString + "\n    "))]
        )
        """
    }
    var debugDescription: String {
        return description
    }
}
