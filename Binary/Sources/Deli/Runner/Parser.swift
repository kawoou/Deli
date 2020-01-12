//
//  Parser.swift
//  Deli
//

import Foundation
import SourceKittenFramework

final class Parser: Runnable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let allowKinds = [
            SwiftDeclarationKind.class.rawValue,
            SwiftDeclarationKind.struct.rawValue,
            SwiftDeclarationKind.protocol.rawValue,
            SwiftDeclarationKind.typealias.rawValue
        ]
        static let allowAccessLevels = [
            Structure.AccessLevel.open,
            Structure.AccessLevel.public,
            Structure.AccessLevel.internal
        ]
    }
    
    // MARK: - Property
    
    let moduleList: [Parsable]
    
    // MARK: - Private
    
    private var inheritanceMap = [String: InheritanceInfo]()
    
    private func parse(structure: Structure, content: String, prefix: String = "") throws -> [Results] {
        guard let name = structure.name.map({ prefix + $0 }) else { return [] }
        
        /// Compare allowed keywords
        guard Constant.allowKinds.contains(structure.kind) else { return [] }
        
        /// Compares allowed AccessLevels
        guard Constant.allowAccessLevels.contains(structure.accessLevel) else { return [] }

        /// Find nested type
        let results = try structure.substructures
            .flatMap { try parse(structure: $0, content: content, prefix: "\(name).") }
        
        /// Save inheritance information
        inheritanceMap[name] = InheritanceInfo(
            name: name,
            types: structure.inheritedTypes,
            structure: structure,
            content: content
        )
        
        /// Parsing
        return try moduleList
            .flatMap { parsable -> [Results] in
                let dependencies = try parsable.dependency
                    .flatMap { try $0.parse(by: structure, fileContent: content) }
                
                return try parsable
                    .parse(by: structure, fileContent: content)
                    .map { result in
                        result.dependencies.append(contentsOf: dependencies)
                        return result
                    }
            } + results
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
