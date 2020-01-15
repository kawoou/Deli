//
//  ComponentParser.swift
//  Deli
//

import SourceKittenFramework

final class ComponentParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = "Component"
    }

    // MARK: - Public
    
    func parse(
        by source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: String]
    ) throws -> [Results] {
        guard let name = source.name.map({ typePrefix + $0 }) else { return [] }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }
        
        let scope = try parseScope(source, fileContent: fileContent)
        let qualifier = try parseQualifier(source, fileContent: fileContent)
        return [
            ComponentResult(
                name,
                scope: scope,
                qualifier: qualifier,
                valueType: source.kind == SwiftDeclarationKind.struct.rawValue
            )
        ]
    }
}
