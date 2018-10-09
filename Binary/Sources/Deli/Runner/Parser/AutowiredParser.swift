//
//  AutowiredParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class AutowiredParser: Parsable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let inheritanceName = "Autowired"
        static let constructorPrefix = "init("
        
        static let requiredKey = "source.decl.attribute.required"
        
        static let typeRegex = "^([^.]+\\.)?(Dep[\\d]+)$".r!
        static func typealiasRegex(_ type: String) -> Regex {
            return "typealias[\\s]+\(type)[\\s]*=[\\s]*([^\\n]+)".r!
        }
        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!
    }
    
    // MARK: - Private

    private func convert(name: String, fileContent: String) -> String? {
        guard let nameMatch = Constant.typeRegex.findFirst(in: name) else { return name }
        guard let nameResult = nameMatch.group(at: 2) else { return name }
        
        let dependencyName = nameResult
        
        guard let typeMatch = Constant.typealiasRegex(dependencyName).findFirst(in: fileContent) else { return nil }
        guard let typeResult = typeMatch.group(at: 1) else { return nil }
        return typeResult
    }
    
    private func validConstructor(_ source: Structure, fileContent: String) -> Bool {
        guard let name = source.name else { return false }
        guard source.attributes.contains(Constant.requiredKey) else { return false }
        guard let code = fileContent.utf8[Int(source.offset)...Int(source.offset + source.length)] else { return false }
        guard code.hasPrefix(Constant.constructorPrefix) else { return false }
        guard name.hasPrefix(Constant.constructorPrefix) else { return false }
        return true
    }
    
    // MARK: - Public
    
    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }
        
        let constructorList = source.substructures
            .filter { validConstructor($0, fileContent: fileContent) }

        guard let constructor = constructorList.first else {
            Logger.log(.error("Not found `\(name)` constructor.", source.getSourceLine(with: fileContent)))
            throw ParserError.constructorNotFound
        }
        guard constructorList.count == 1 else {
            for constructor in constructorList {
                Logger.log(.error("Ambiguous `\(name)` constructor.", constructor.getSourceLine(with: fileContent)))
            }
            throw ParserError.constructorAmbiguous
        }
        
        let qualifierList = constructor
            .name?
            .utf8[Constant.constructorPrefix.count...]?
            .split(separator: ":")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0 == "_" ? "" : $0 } ?? []
        
        let scope = try parseScope(source, fileContent: fileContent)
        let qualifier = try parseQualifier(source, fileContent: fileContent)
        let dependencies = try constructorList
            .flatMap { $0.substructures }
            .filter { $0.kind == SwiftDeclarationKind.varParameter.rawValue }
            .enumerated()
            .map { (index, info) -> Dependency in
                guard let typeName = info.typeName else {
                    Logger.log(.error("Unknown `\(name)` dependency type.", info.getSourceLine(with: fileContent)))
                    throw ParserError.typeNotFound
                }
                guard let dependencyName = convert(name: typeName, fileContent: fileContent) else {
                    Logger.log(.error("Not found an aliased type named `\(name).\(typeName)`.", info.getSourceLine(with: fileContent)))
                    throw ParserError.typeNotFound
                }
                
                let qualifier = qualifierList[index]

                if let arrayType = Constant.arrayRegex.findFirst(in: dependencyName)?.group(at: 1) {
                    return Dependency(
                        parent: name,
                        target: constructor,
                        name: arrayType,
                        type: .array,
                        qualifier: qualifier
                    )
                }
                return Dependency(
                    parent: name,
                    target: constructor,
                    name: dependencyName,
                    qualifier: qualifier
                )
            }
        
        return [AutowiredConstructorResult(name, scope, qualifier, dependencies)]
    }
}
