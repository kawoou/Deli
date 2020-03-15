//
//  Parser.swift
//  Deli
//

import Foundation
import Regex
import SourceKittenFramework

final class Parser: Runnable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let allowKinds = [
            SwiftDeclarationKind.class.rawValue,
            SwiftDeclarationKind.struct.rawValue,
            SwiftDeclarationKind.protocol.rawValue
        ]
        static let allowAccessLevels = [
            Structure.AccessLevel.open,
            Structure.AccessLevel.public,
            Structure.AccessLevel.internal
        ]

        static let typealiasRegex = "typealias[\\s]+([^\\s=]+)[\\s]*=[\\s]*([^\\n]+)".r!
    }
    
    // MARK: - Property
    
    let moduleList: [Parsable]
    
    // MARK: - Private
    
    private var inheritanceMap = [String: InheritanceInfo]()

    private func parseTypealias(structure: Structure, content: String) -> String? {
        guard let data = content.utf8[Int(structure.offset)..<Int(structure.offset + structure.length)] else { return nil }
        guard let typeMatch = Constant.typealiasRegex.findFirst(in: data) else {
            Logger.log(.debug("Failed to parse file content for 'typealias' keyword"))
            return nil
        }
        guard let typeName = typeMatch.group(at: 1) else { return nil }
        guard let typeResult = typeMatch.group(at: 2) else { return nil }
        guard typeName == structure.name else {
            Logger.log(.debug(
                "Type dismatch between SourceKitten and file content " +
                "(SourceKitten: \(structure.name ?? ""), file content: \(typeName))"
            ))
            return nil
        }
        return typeResult
    }
    
    private func parse(
        structure: Structure,
        content: String,
        typePrefix: String = "",
        typealiasMap: [String: String] = [:]
    ) throws -> [Results] {
        guard let name = structure.name.map({ typePrefix + $0 }) else { return [] }
        
        /// Compare allowed keywords
        guard Constant.allowKinds.contains(structure.kind) else { return [] }
        
        /// Compares allowed AccessLevels
        guard Constant.allowAccessLevels.contains(structure.accessLevel) else { return [] }

        /// Saved typealias
        var typealiasMap = typealiasMap
        structure.substructures
            .filter { $0.kind == SwiftDeclarationKind.typealias.rawValue }
            .forEach { structure in
                guard let typeName = structure.name else { return }
                guard let typeResult = parseTypealias(structure: structure, content: content) else { return }

                typealiasMap[typeName] = typeResult
                typealiasMap["\(name).\(typeName)"] = typeResult
            }

        /// Find nested type
        let results = try structure.substructures
            .flatMap {
                try parse(
                    structure: $0,
                    content: content,
                    typePrefix: "\(name).",
                    typealiasMap: typealiasMap
                )
            }

        /// Save inheritance information
        inheritanceMap[name] = InheritanceInfo(
            name: name,
            types: structure.inheritedTypes,
            structure: structure,
            content: content
        )
        
        /// Parsing
        let parseResults = try moduleList
            .flatMap { parsable -> [Results] in
                let dependencies = try parsable.dependency
                    .flatMap {
                        try $0.parse(
                            by: structure,
                            fileContent: content,
                            typePrefix: typePrefix,
                            typealiasMap: typealiasMap
                        )
                    }
                
                return try parsable
                    .parse(
                        by: structure,
                        fileContent: content,
                        typePrefix: typePrefix,
                        typealiasMap: typealiasMap
                    )
                    .map { result in
                        result.dependencies.append(contentsOf: dependencies)
                        return result
                    }
            } + results

        return parseResults
    }
    
    private func parse(path: String) throws -> [Results] {
        let url = URL(fileURLWithPath: path).standardized

        let content = try String(contentsOfFile: path, encoding: .utf8)

        /// Analysis the source code
        let info = (try? KittenStructure(file: File(contents: content)).dictionary) ?? [:]
        guard let rootStructure = RootStructure(source: info, filePath: url.path) else {
            Logger.log(.debug("Failed to parse the source code in SourceKitten. (\(path))"))
            return []
        }
        
        /// Parsing
        return try rootStructure.substructures
            .flatMap { try parse(structure: $0, content: content) }
    }
    
    // MARK: - Public
    
    func inheritanceList(_ name: String) -> [InheritanceInfo] {
        guard let info = inheritanceMap[name] else { return [] }
        var inheritanceList = [InheritanceInfo]()
        var queue = info.types
        while let item = queue.popLast() {
            guard let info = inheritanceMap[item] else { continue }
            queue.append(contentsOf: info.types)
            inheritanceList.append(info)
        }
        return [info] + inheritanceList
    }
    
    func run(_ pathList: [String]) throws -> [Results] {
        return try pathList.flatMap { try parse(path: $0) }
    }
    func reset() {
        inheritanceMap = [:]
    }
    
    // MARK: - Lifecycle
    
    required init(_ modules: [Parsable]) {
        self.moduleList = modules
    }
}
