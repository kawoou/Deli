//
//  LazyAutowiredFactoryParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class LazyAutowiredFactoryParser: Parsable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let inheritanceName = "LazyAutowiredFactory"
        static let constructorPrefix = "init("
        static let injectorPrefix = "inject("
        
        static let requiredKey = "source.decl.attribute.required"
        
        static let payloadKey = "payload"
        static let payloadTypeRegex = "^([^.]+\\.)?(_Payload)$".r!
        
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
    private func convertPayload(name: String, fileContent: String) -> String? {
        guard let nameMatch = Constant.payloadTypeRegex.findFirst(in: name) else { return name }
        guard let payloadName = nameMatch.group(at: 2) else { return name }
        
        guard let typeMatch = Constant.typealiasRegex(payloadName).findFirst(in: fileContent) else { return nil }
        guard let typeResult = typeMatch.group(at: 1) else { return nil }
        return typeResult
    }
    
    private func validConstructor(_ source: Structure) -> Bool {
        guard let name = source.name else { return false }
        guard name.hasPrefix(Constant.constructorPrefix) else { return false }
        guard source.attributes.contains(Constant.requiredKey) else { return false }
        
        guard let parameter = source.substructures.first else { return false }
        guard parameter.kind == SwiftDeclarationKind.varParameter.rawValue else { return false }
        guard parameter.name == Constant.payloadKey else { return false }
        return true
    }
    private func validInjector(_ source: Structure) -> Bool {
        guard let name = source.name else { return false }
        guard name.hasPrefix(Constant.injectorPrefix) else { return false }
        guard source.substructures.count > 0 else { return false }
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
            .filter { validConstructor($0) }
        let injectorList = source.substructures
            .filter { validInjector($0) }
        
        guard constructorList.count > 0 else {
            Logger.log(.error("Not found `\(name)` constructor.", source.getSourceLine(with: fileContent)))
            throw ParserError.constructorNotFound
        }
        guard constructorList.count == 1 else {
            for constructor in constructorList {
                Logger.log(.error("Ambiguous `\(name)` constructor.", constructor.getSourceLine(with: fileContent)))
            }
            throw ParserError.constructorAmbiguous
        }
        
        guard injectorList.count > 0 else {
            Logger.log(.error("Not found `\(name)` injector.", source.getSourceLine(with: fileContent)))
            throw ParserError.injectorNotFound
        }
        guard injectorList.count == 1 else {
            for injector in injectorList {
                Logger.log(.error("Ambiguous `\(name)` injector.", injector.getSourceLine(with: fileContent)))
            }
            throw ParserError.injectorAmbiguous
        }
        
        let qualifierList = injectorList.first?
            .name?[Constant.injectorPrefix.count...]
            .split(separator: ":")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0 == "_" ? "" : $0 } ?? []
        
        let parameterList = injectorList
            .flatMap { $0.substructures }
            .filter { $0.kind == SwiftDeclarationKind.varParameter.rawValue }
        
        let qualifier = try parseQualifier(source, fileContent: fileContent)
        let dependencies = try parameterList
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
                        target: injectorList.first,
                        name: arrayType,
                        type: .array,
                        qualifier: qualifier
                    )
                }
                return Dependency(
                    parent: name,
                    target: injectorList.first,
                    name: dependencyName,
                    qualifier: qualifier
                )
        }
        
        let payload: Dependency = try {
            let constructor = constructorList[0]
            guard let info = constructor.substructures.first else {
                Logger.log(.error("Not found payload type.", constructor.getSourceLine(with: fileContent)))
                throw ParserError.payloadNotFound
            }
            guard let typeName = info.typeName else {
                Logger.log(.error("Not found payload type.", info.getSourceLine(with: fileContent)))
                throw ParserError.payloadNotFound
            }
            guard let payloadName = convertPayload(name: typeName, fileContent: fileContent) else {
                Logger.log(.error("Not found an aliased type named `\(name).\(typeName)`.", info.getSourceLine(with: fileContent)))
                throw ParserError.payloadNotFound
            }
            
            return Dependency(
                parent: name,
                target: constructor,
                name: payloadName
            )
        }()
        
        return [LazyAutowiredFactoryConstructorResult(name, qualifier, dependencies, payload: payload)]
    }
    
}
