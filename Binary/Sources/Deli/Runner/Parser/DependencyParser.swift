//
//  DependencyParser.swift
//  deli
//
//  Created by Kawoou on 2020/03/06.
//

import SourceKittenFramework

final class DependencyParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let propertyWrapperArray = "DependencyArray"

        static let propertyWrapperRegex = "@(DependencyArray|Dependency)(\\(([^\\(]*(\\([^\\)]*\\))*[^\\)]*)\\))?".r!

        static let qualifierName = "qualifier"
        static let qualifierPrefix = "\(qualifierName):"
        static let qualifierRegex = "\(qualifierName):[\\s]*\"([^\"]*)\"".r!

        static let qualifierByName = "qualifierBy"
        static let qualifierByPrefix = "\(qualifierByName):"
        static let qualifierByRegex = "\(qualifierByName):[\\s]*\"([^\"]*)\"".r!

        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!
    }

    // MARK: - Private

    private func found(
        _ source: Structure,
        root: Structure,
        fileContent: String,
        typealiasMap: [String: [String]]
    ) throws -> [Dependency]? {
        guard let rootName = root.name else { return nil }
        guard let typeName = source.typeName else { return nil }

        guard let attributeOffset = source.attributeOffsets.first else { return nil }
        guard let attributeLength = source.attributeLengths.first else { return nil }
        guard let attributeName = fileContent.utf8[Int(attributeOffset)..<Int(attributeOffset + attributeLength)] else { return nil }

        guard let match = Constant.propertyWrapperRegex.findFirst(in: attributeName) else { return nil }
        guard let target = match.group(at: 1) else { return nil }

        let arguments = (match.group(at: 3) ?? "").split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let qualifier = arguments
            .first { $0.hasPrefix(Constant.qualifierPrefix) }
            .flatMap { result -> String? in
                guard let match = Constant.qualifierRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let qualifierBy = arguments
            .first { $0.hasPrefix(Constant.qualifierByName) }
            .flatMap { result -> String? in
                guard let match = Constant.qualifierByRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let arrayMatch = Constant.arrayRegex.findFirst(in: typeName), let arrayType = arrayMatch.group(at: 1) {
            if target == Constant.propertyWrapperArray {
                return (typealiasMap[arrayType] ?? [arrayType]).map {
                    Dependency(
                        parent: rootName,
                        target: source,
                        name: $0,
                        type: .array,
                        rule: .default,
                        qualifier: qualifier,
                        qualifierBy: qualifierBy
                    )
                }
            } else {
                Logger.log(.error("Use @DependencyArray for the Array type.", source.getSourceLine(with: fileContent)))
                throw ParserError.useDependencyArray
            }
        } else {
            return (typealiasMap[typeName] ?? [typeName]).map {
                Dependency(
                    parent: rootName,
                    target: source,
                    name: $0,
                    rule: .default,
                    qualifier: qualifier,
                    qualifierBy: qualifierBy
                )
            }
        }
    }

    // MARK: - Public

    func parse(
        by source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: [String]]
    ) throws -> [Results] {
        guard let name = source.name.map({ typePrefix + $0 }) else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }

        let dependencyList = try source.substructures
            .filter { $0.attributes.contains(SwiftDeclarationAttributeKind._custom.rawValue) }
            .flatMap {
                try found(
                    $0,
                    root: source,
                    fileContent: fileContent,
                    typealiasMap: typealiasMap
                ) ?? []
            }

        guard !dependencyList.isEmpty else { return [] }

        return [
            InjectProtocolResult(
                name,
                dependencies: dependencyList,
                valueType: source.kind == SwiftDeclarationKind.struct.rawValue
            )
        ]
    }
}
