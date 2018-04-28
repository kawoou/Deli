//
//  ConfigurationParser.swift
//  Deli
//

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

        static let availableKinds: [String] = [
            SwiftDeclarationKind.varInstance.rawValue,
            SwiftDeclarationKind.varStatic.rawValue,
            SwiftDeclarationKind.functionMethodClass.rawValue,
            SwiftDeclarationKind.functionMethodStatic.rawValue
        ]
    }
    
    // MARK: - Private
    
    private func convert(_ source: Structure, parent: Structure, fileContent: String) throws -> ConfigFunctionResult {
        guard let name = parent.name else {
            throw ParserError.unknown
        }

        /// Raw arguments
        let rawArguments = source.substructures
            .map { info -> String in
                return fileContent[Int(info.offset)..<Int(info.offset + info.length)]
                    .replacingOccurrences(of: Constant.typeRefererSuffix, with: "")
            }
        
        guard rawArguments.count > 0 else {
            Logger.log(.error("The `\(Constant.functionName)` method in `\(name)` required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }

        /// Safe arguments
        let instanceType = rawArguments[0]
        let arguments: [String] = {
            guard rawArguments.count > 1 else { return [] }
            return Array(rawArguments[1..<(rawArguments.count - 1)])
        }()

        /// Read information
        let dependencies = arguments
            /// Remove unnecessary arguments.
            .filter { $0.index(of: Constant.argumentInfoKeyword) == nil }
            .map { Dependency(parent: name, target: source, name: $0) }

        let qualifier = arguments
            .first(where: { $0.contains(Constant.qualifierPrefix) })?
            .replacingOccurrences(of: Constant.qualifierPrefix, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let scope = arguments
            .first(where: { $0.contains(Constant.scopePrefix) })?
            .replacingOccurrences(of: Constant.scopePrefix, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        /// Get previous context
        guard let index = parent.substructures.index(where: { $0 === source }) else {
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
        guard let variableName = prevSource.name else {
            Logger.log(.error("Not found to stored name in `\(name)`.", prevSource.getSourceLine(with: fileContent)))
            throw ParserError.unavailableDeclaration
        }
        guard Constant.availableKinds.contains(prevSource.kind) else {
            Logger.log(.error("Not allowed `\(name).\(variableName)` declaration.", prevSource.getSourceLine(with: fileContent)))
            throw ParserError.unavailableDeclaration
        }

        /// Result
        return ConfigFunctionResult(
            instanceType,
            scope,
            qualifier,
            dependencies,
            parentInstanceType: name,
            variableName: variableName
        )
    }
    
    private func validFunction(_ source: Structure) -> Bool {
        guard source.name == Constant.functionName else { return false }
        guard source.kind == Constant.functionCallKey else { return false }
        return true
    }
    
    // MARK: - Public
    
    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }
        
        return try source.substructures
            .filter { validFunction($0) }
            .map { try convert($0, parent: source, fileContent: fileContent) } +
            [ConfigurationResult(name)]
    }
}
