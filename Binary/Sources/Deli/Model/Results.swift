//
//  Results.swift
//  Deli
//

protocol Results: class, CustomStringConvertible, CustomDebugStringConvertible {
    var isLazy: Bool { get }
    var isFactory: Bool { get }
    var isRegister: Bool { get }
    var instanceType: String { get }
    var scope: String? { get set }
    var qualifier: String? { get set }
    var dependencies: [Dependency] { get set }

    var linkType: Set<String> { get set }
    
    func makeSource() -> String?
}
extension Results {
    func makeSource() -> String? {
        return nil
    }
    var description: String {
        let dependenciesString = dependencies
            .map { dependency in
                return "\(dependency.name)(type: \(dependency.type), qualifier: \"\(dependency.qualifier)\")"
            }
            .joined(separator: ",\n        ")
        
        let linkTypeString = linkType
            .joined(separator: ",\n        ")
        
        return """
        \(instanceType)(
            isLazy: \(isLazy),
            isFactory: \(isFactory),
            isRegister: \(isRegister),
            scope: \(scope ?? ".singleton"),
            qualifier: \"\(qualifier ?? "")\",
            dependencies: [\(dependenciesString.isEmpty ? "" : ("\n        " + dependenciesString + "\n    "))],
            linkType: [\(linkTypeString.isEmpty ? "" : ("\n        " + linkTypeString + "\n    "))]
        )
        """
    }
    var debugDescription: String {
        return description
    }
}
