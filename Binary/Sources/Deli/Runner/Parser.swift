//
//  Parser.swift
//  Deli
//

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
    }
    
    // MARK: - Property
    
    let moduleList: [Parsable]
    
    // MARK: - Private
    
    private var inheritanceMap = [String: [String]]()
    
    private func parse(structure: Structure, content: String) throws -> [Results] {
        guard let name = structure.name else { return [] }
        
        /// Compare allowed keywords
        guard Constant.allowKinds.contains(structure.kind) else { return [] }
        
        /// Compares allowed AccessLevels
        guard Constant.allowAccessLevels.contains(structure.accessLevel) else { return [] }
        
        /// Save inheritance information
        inheritanceMap[name] = structure.inheritedTypes
        
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
        let content = try String(contentsOfFile: path, encoding: .utf8)
        
        /// Analysis the source code
        let info = (try? KittenStructure(file: File(contents: content)).dictionary) ?? [:]
        guard let rootStructure = RootStructure(source: info) else {
            Logger.log(.debug("Failed to parse the source code in SourceKitten. (\(path))"))
            return []
        }
        
        /// Parsing
        return try rootStructure.substructures
            .flatMap { try parse(structure: $0, content: content) }
    }
    
    // MARK: - Public
    
    func inheritanceList(_ name: String) -> [String] {
        var inheritanceList = inheritanceMap[name] ?? []
        var queue = inheritanceList
        while let item = queue.popLast() {
            guard let list = inheritanceMap[item] else { continue }
            queue.append(contentsOf: list)
            inheritanceList.append(contentsOf: list)
        }
        return inheritanceList
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
