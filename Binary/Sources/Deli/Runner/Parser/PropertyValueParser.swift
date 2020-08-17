//
//  PropertyValueParser.swift
//  deli
//
//  Created by Kawoou on 2020/03/06.
//

import SourceKittenFramework

final class PropertyValueParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let propertyWrapper = "PropertyValue"

        static let propertyWrapperRegex = "@(PropertyValue)(\\(([^\\(]*(\\([^\\)]*\\))*[^\\)]*)\\))?".r!

        static let pathParseRegEx = "\"((\\\"|[^\\\"]+)+)\"".r!
    }

    // MARK: - Private

    private func found(
        _ source: Structure,
        root: Structure,
        fileContent: String
    ) throws -> String? {
        guard let attributeOffset = source.attributeOffsets.first else { return nil }
        guard let attributeLength = source.attributeLengths.first else { return nil }
        guard let attributeName = fileContent.utf8[Int(attributeOffset)..<Int(attributeOffset + attributeLength)] else { return nil }

        guard let match = Constant.propertyWrapperRegex.findFirst(in: attributeName) else { return nil }
        guard let target = match.group(at: 1) else { return nil }
        guard target == Constant.propertyWrapper else { return nil }

        guard let path = Constant.pathParseRegEx.findFirst(in: attributeName)?.group(at: 1) else {
            Logger.log(.error("The `\(Constant.propertyWrapper)` property wrapper required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }
        return path
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

        let pathList = try source.substructures
            .filter { $0.attributes.contains(SwiftDeclarationAttributeKind._custom.rawValue) }
            .compactMap {
                try found($0, root: source, fileContent: fileContent)
            }

        guard !pathList.isEmpty else { return [] }

        return [
            InjectPropertyResult(
                name,
                propertyKeys: pathList,
                valueType: source.kind == SwiftDeclarationKind.struct.rawValue
            )
        ]
    }
}
