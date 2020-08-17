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
            SwiftDeclarationKind.protocol.rawValue,
            SwiftDeclarationKind.extension.rawValue
        ]

        static let allowAccessLevels = [
            Structure.AccessLevel.open,
            Structure.AccessLevel.public,
            Structure.AccessLevel.internal
        ]

        static let parseKinds = [
            SwiftDeclarationKind.class.rawValue,
            SwiftDeclarationKind.struct.rawValue,
            SwiftDeclarationKind.protocol.rawValue
        ]

        static let inheritedKinds = parseKinds + [
            SwiftDeclarationKind.typealias.rawValue
        ]

        static let typealiasRegex = "typealias[\\s]+([^\\s=]+)[\\s]*=[\\s]*([^\\n]+)".r!
    }
    
    // MARK: - Property
    
    let moduleList: [Parsable]
    
    // MARK: - Private

    private var cacheLock = NSLock()
    private var cachedStructures = [String: RootStructure]()
    private var inheritanceMap = [String: InheritanceInfo]()

    private func parseTypealias(structure: Structure, content: String) -> [String]? {
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
        return typeResult.split(separator: "&")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    private func parse(
        structure: Structure,
        content: String,
        typePrefix: String = "",
        typealiasMap: [String: [String]] = [:]
    ) throws -> [Results] {
        guard let name = structure.name.map({ typePrefix + $0 }) else { return [] }

        if structure.kind == SwiftDeclarationKind.typealias.rawValue {
            /// Save inheritance information
            inheritanceMap[name] = InheritanceInfo(
                name: name,
                types: structure.inheritedTypes.flatMap { (typealiasMap[$0] ?? []) + [$0] },
                structure: structure,
                content: content
            )
        }

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
            .sorted(by: sortStructureByKind)
            .flatMap {
                try parse(
                    structure: $0,
                    content: content,
                    typePrefix: "\(name).",
                    typealiasMap: typealiasMap
                )
            }

        /// Compare allowed keywords
        guard Constant.parseKinds.contains(structure.kind) else { return results }

        /// Save inheritance information
        inheritanceMap[name] = InheritanceInfo(
            name: name,
            types: structure.inheritedTypes.flatMap { (typealiasMap[$0] ?? []) + [$0] },
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
            }

        return parseResults + results
    }
    
    private func parse(path: String, typealiasMap: [String: [String]]) throws -> [Results] {
        /// Analysis the source code
        guard let rootStructure = try loadStructure(from: path) else {
            Logger.log(.debug("Failed to parse the source code in SourceKitten. (\(path))"))
            return []
        }
        
        /// Parsing
        return try rootStructure.substructures
            .sorted(by: sortStructureByKind)
            .flatMap { try parse(structure: $0, content: rootStructure.content, typealiasMap: typealiasMap) }
    }

    private func parseRootTypealiasMap(_ pathList: [String]) -> [String: [String]] {
        var typealiasMap = [String: [String]]()

        try? pathList.forEach { path in
            /// Analysis the source code
            guard let rootStructure = try loadStructure(from: path) else {
                Logger.log(.debug("Failed to parse the source code in SourceKitten. (\(path))"))
                return
            }

            rootStructure.substructures
                .filter { $0.kind == SwiftDeclarationKind.typealias.rawValue }
                .forEach { structure in
                    guard let typeName = structure.name else { return }
                    guard let typeResult = parseTypealias(structure: structure, content: rootStructure.content) else { return }

                    typealiasMap[typeName] = typeResult
                }
        }

        return typealiasMap
    }

    private func sortStructureByKind(_ lhs: Structure, _ rhs: Structure) -> Bool {
        let orderKey: (Structure) -> Int = { structure in
            switch structure.kind {
            case SwiftDeclarationKind.typealias.rawValue:
                return 1
            case SwiftDeclarationKind.class.rawValue,
                 SwiftDeclarationKind.struct.rawValue,
                 SwiftDeclarationKind.protocol.rawValue:
                return 2
            case SwiftDeclarationKind.extension.rawValue:
                return 3
            default:
                return 4
            }
        }

        return orderKey(lhs) < orderKey(rhs)
    }

    private func loadStructure(from path: String) throws -> RootStructure? {
        cacheLock.lock()
        if let structure = cachedStructures[path] {
            cacheLock.unlock()
            return structure
        } else {
            cacheLock.unlock()
        }

        let url = URL(fileURLWithPath: path).standardized
        let content = try String(contentsOfFile: path, encoding: .utf8)

        let info = (try? KittenStructure(file: File(contents: content)).dictionary) ?? [:]
        let structure = RootStructure(source: info, filePath: url.path, content: content)

        cacheLock.lock()
        cachedStructures[path] = structure
        cacheLock.unlock()

        return structure
    }

    private func loadAllStructure(from pathList: [String]) {
        let dispatchGroup = DispatchGroup()

        pathList.forEach { path in
            dispatchGroup.enter()
            DispatchQueue.global().async {
                _ = try? self.loadStructure(from: path)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()
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
        loadAllStructure(from: pathList)
        
        let typealiasMap = parseRootTypealiasMap(pathList)
        return try pathList.flatMap { try parse(path: $0, typealiasMap: typealiasMap) }
    }
    func reset() {
        cachedStructures = [:]
        inheritanceMap = [:]
    }
    
    // MARK: - Lifecycle
    
    required init(_ modules: [Parsable]) {
        self.moduleList = modules
    }
}
