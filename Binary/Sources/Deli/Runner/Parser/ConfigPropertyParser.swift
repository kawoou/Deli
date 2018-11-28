//
//  ConfigPropertyParser.swift
//  Deli
//
//  Created by Kawoou on 28/11/2018.
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

    private func convert(_ source: Structure, fileContent: String) throws -> ConfigPropertyResult {
        guard let name = source.name else {
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
            .compactMap { $0.name }
            .filter { $0 != Constant.targetPropertyName }

        return ConfigPropertyResult(
            name,
            targetPath,
            propertyList,
            valueType: source.kind == SwiftDeclarationKind.struct.rawValue
        )
    }

    // MARK: - Public

    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard source.name != nil else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }

        return [try convert(source, fileContent: fileContent)]
    }
}
