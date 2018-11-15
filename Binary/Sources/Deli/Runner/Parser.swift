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
            SwiftDeclarationKind.struct.rawValue
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
    
    private func parse(structure: Structure, content: String) throws -> [Results] {
        guard let name = structure.name else { return [] }
        
        /// Compare allowed keywords
        guard Constant.allowKinds.contains(structure.kind) else { return [] }
        
        /// Compares allowed AccessLevels
        guard Constant.allowAccessLevels.contains(structure.accessLevel) else { return [] }
        
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
            }
    }
    
    private func parse(path: String) throws -> [Results] {
        guard let url = URL(string: path)?.standardized else {
            Logger.log(.warn("Failed to create URL: \(path)", nil))
            return []
        }

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
        moduleList = modules
    }
}
