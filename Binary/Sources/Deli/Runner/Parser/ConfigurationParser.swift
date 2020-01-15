//
//  ConfigurationParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class ConfigurationParser: Parsable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let inheritanceName = "Configuration"
        static let functionName = "Config"
        static let functionCallKey = "source.lang.swift.expr.call"

        static let typeRefererSuffix = ".self"
        static let argumentInfoKeyword: Character = ":"
        static let qualifierPrefix = "qualifier:"
        static let scopePrefix = "scope:"

        static let qualifierClearRegex = "\"([^\\\"]+)\"".r!

        static let importRegex = "\\nimport ([^\\s]+)".r!
        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!

        static let availableKinds: [String] = [
            SwiftDeclarationKind.varInstance.rawValue,
            SwiftDeclarationKind.varStatic.rawValue,
            SwiftDeclarationKind.functionMethodClass.rawValue,
            SwiftDeclarationKind.functionMethodStatic.rawValue
        ]
    }
    
    // MARK: - Private

    private let injectParser = InjectParser()
    
    private func convert(
        _ source: Structure,
        parent: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: String]
    ) throws -> ConfigFunctionResult {
        guard let name = parent.name else {
            throw ParserError.unknown
        }

        /// Get previous context
        guard let index = parent.substructures.firstIndex(where: { $0 === source }) else {
            Logger.log(.assert("Not found the index of current structure on \(name)."))
            Logger.log(.error("Unknown error in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.unknown
        }
        guard index > 0 else {
            Logger.log(.assert("The `\(Constant.functionName)` method call position that can not exist."))
            Logger.log(.error("Unknown error in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.unknown
        }

        let prevSource = parent.substructures[index - 1]

        /// Raw arguments
        let rawArguments = source.substructures
            .map { info -> String in
                return fileContent
                    .utf8[Int(info.offset)..<Int(info.offset + info.length)]?
                    .replacingOccurrences(of: Constant.typeRefererSuffix, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
        
        guard let instanceType = rawArguments.first else {
            Logger.log(.error("The `\(Constant.functionName)` method in `\(name)` required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }

        /// Safe arguments
        let arguments: [String] = {
            guard rawArguments.count > 1 else { return [] }
            return Array(rawArguments[1..<(rawArguments.count - 1)])
        }()

        /// Read information
        let dependencies = try arguments
            /// Remove unnecessary arguments.
            .filter { $0.firstIndex(of: Constant.argumentInfoKeyword) == nil }
            .map { dependencyName -> Dependency in
                if Constant.arrayRegex.findFirst(in: dependencyName)?.group(at: 1) != nil {
                    Logger.log(.error("Configuration does not support injection for Array type Dependency. Using `Inject(\(dependencyName).self)`.", source.getSourceLine(with: fileContent)))
                    throw ParserError.configurationCannotSupportArrayType
                }
                return Dependency(
                    parent: name,
                    target: source,
                    name: typealiasMap[dependencyName] ?? dependencyName
                )
            }

        let qualifierRaw = arguments
            .first { $0.contains(Constant.qualifierPrefix) }?
            .replacingOccurrences(of: Constant.qualifierPrefix, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let qualifier: String? = try {
            guard let raw = qualifierRaw else { return nil }
            guard let match = Constant.qualifierClearRegex.findFirst(in: raw)?.group(at: 1) else {
                Logger.log(.error("Unavailable qualifier `\(raw)`.", source.getSourceLine(with: fileContent)))
                throw ParserError.qualifierUnavailable
            }
            return match
        }()
        
        let scope = arguments
            .first { $0.contains(Constant.scopePrefix) }?
            .replacingOccurrences(of: Constant.scopePrefix, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let variableName = prevSource.name else {
            Logger.log(.error("Not found to stored name in `\(name)`.", prevSource.getSourceLine(with: fileContent)))
            throw ParserError.unavailableDeclaration
        }
        guard Constant.availableKinds.contains(prevSource.kind) else {
            Logger.log(.error("Not allowed `\(name).\(variableName)` declaration.", prevSource.getSourceLine(with: fileContent)))
            throw ParserError.unavailableDeclaration
        }

        let imports = Constant.importRegex
            .findAll(in: fileContent)
            .compactMap { $0.group(at: 1) }

        let injectResults = try injectParser.parse(
            by: source,
            fileContent: fileContent,
            isInheritanceCheck: false,
            typePrefix: typePrefix,
            typealiasMap: typealiasMap
        )

        /// Result
        return ConfigFunctionResult(
            instanceType,
            scope: scope,
            qualifier: qualifier,
            dependencies: dependencies + injectResults.flatMap { $0.dependencies },
            imports: imports,
            parentInstanceType: name,
            variableName: variableName,
            valueType: false
        )
    }
    
    private func validFunction(_ source: Structure) -> Bool {
        guard source.name == Constant.functionName else { return false }
        guard source.kind == Constant.functionCallKey else { return false }
        return true
    }
    
    // MARK: - Public
    
    func parse(
        by source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: String]
    ) throws -> [Results] {
        guard let name = source.name.map({ typePrefix + $0 }) else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }
        
        return try source.substructures
            .filter { validFunction($0) }
            .map {
                try convert(
                    $0,
                    parent: source,
                    fileContent: fileContent,
                    typePrefix: typePrefix,
                    typealiasMap: typealiasMap
                )
            } +
            [
                ConfigurationResult(
                    name,
                    valueType: source.kind == SwiftDeclarationKind.struct.rawValue
                )
            ]
    }
}
