//
//  ConfigPropertyParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class ConfigPropertyParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = "ConfigProperty"

        static let targetPropertyName = "target"
        static let targetPropertyParseRegEx = "\"((\\\"|[^\\\"]+)+)\"".r!
    }

    // MARK: - Private

    private func convert(
        _ source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: String]
    ) throws -> ConfigPropertyResult {
        guard let name = source.name.map({ typePrefix + $0 }) else {
            throw ParserError.unknown
        }

        let properties = source.substructures
            .filter { $0.kind == SwiftDeclarationKind.varInstance.rawValue }

        /// Target
        guard let target = properties.first(where: { $0.name == Constant.targetPropertyName }) else {
            Logger.log(.debug("Not found `target` property in `\(name)` source code."))
            Logger.log(.error("Configuration property does not found in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.targetPropertyNotFound
        }
        guard let targetValue = fileContent.utf8[Int(target.offset)..<Int(target.offset + target.length)] else {
            Logger.log(.debug("Not found content of `target` property in `\(name)` source code."))
            Logger.log(.error("Configuration property does not found in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.targetPropertyNotFound
        }
        guard let targetPath = Constant.targetPropertyParseRegEx.findFirst(in: targetValue)?.group(at: 1) else {
            Logger.log(.debug("`\(targetValue)` is not matched regular expression pattern in `\(name)` source code."))
            Logger.log(.error("Configuration property does not found in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.targetPropertyNotFound
        }

        let propertyList = properties
            .compactMap { structure -> ConfigPropertyResult.PropertyInfo? in
                guard let type = structure.typeName else { return nil }
                guard let name = structure.name else { return nil }
                guard name != Constant.targetPropertyName else { return nil }

                if type.hasSuffix("?") || type.hasSuffix("!") {
                    return ConfigPropertyResult.PropertyInfo(
                        type: String(type[..<type.index(before: type.endIndex)]),
                        name: name,
                        isOptional: true
                    )
                } else {
                    return ConfigPropertyResult.PropertyInfo(
                        type: type,
                        name: name,
                        isOptional: false
                    )
                }
            }

        return ConfigPropertyResult(
            name,
            propertyTargetKey: targetPath,
            propertyInfos: propertyList,
            valueType: source.kind == SwiftDeclarationKind.struct.rawValue
        )
    }

    // MARK: - Public

    func parse(
        by source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: String]
    ) throws -> [Results] {
        guard source.name != nil else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }

        return [
            try convert(
                source,
                fileContent: fileContent,
                typePrefix: typePrefix,
                typealiasMap: typealiasMap
            )
        ]
    }
}
