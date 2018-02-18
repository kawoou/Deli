//
//  Parsable.swift
//  Deli
//

import SourceKittenFramework

private struct Constant {
    static let scopeName = "scope"
    static let scopeRegex = "\(scopeName)(:[^=]*)?[\\s]*=[\\s]*([^\\s]+)".r!
    
    static let qualifierName = "qualifier"
    static let qualifierRegex = "\(qualifierName)(:[^=]*)?[\\s]*=[\\s]*\"([^\"]*)\"".r!
}

protocol Parsable {
    var dependency: [DependencyParsable] { get }
    
    func parse(by source: Structure, fileContent: String) throws -> [Results]
}
extension Parsable {
    var dependency: [DependencyParsable] {
        return []
    }
    
    func parseScope(_ source: Structure, fileContent: String) throws -> String? {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            throw ParserError.unknownName
        }
        
        let scopeList = source.substructures
            .filter { $0.kind == SwiftDeclarationKind.varInstance.rawValue }
            .filter { $0.name == Constant.scopeName }
        
        guard scopeList.count <= 1 else {
            Logger.log(.error("Ambiguous `\(name)` scope property. \(scopeList)"))
            throw ParserError.scopeAmbiguous
        }

        #if swift(>=4.1)
        return scopeList.compactMap { info in
            let data = fileContent[Int(info.offset)..<Int(info.offset + info.length)]
            guard let match = Constant.scopeRegex.findFirst(in: data) else { return nil }
            return match.group(at: 2)
        }.first
        #else
        return scopeList.flatMap { info in
            let data = fileContent[Int(info.offset)..<Int(info.offset + info.length)]
            guard let match = Constant.scopeRegex.findFirst(in: data) else { return nil }
            return match.group(at: 2)
        }.first
        #endif
    }
    func parseQualifier(_ source: Structure, fileContent: String) throws -> String? {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            throw ParserError.unknownName
        }
        
        let qualifierList = source.substructures
            .filter { $0.kind == SwiftDeclarationKind.varInstance.rawValue }
            .filter { $0.name == Constant.qualifierName }
        
        guard qualifierList.count <= 1 else {
            Logger.log(.error("Ambiguous `\(name)` qualifier property. \(qualifierList)"))
            throw ParserError.qualifierAmbiguous
        }

        #if swift(>=4.1)
        return qualifierList.compactMap { info in
            let data = fileContent[Int(info.offset)..<Int(info.offset + info.length)]
            guard let match = Constant.qualifierRegex.findFirst(in: data) else { return nil }
            return match.group(at: 2)
        }.first
        #else
        return qualifierList.flatMap { info in
            let data = fileContent[Int(info.offset)..<Int(info.offset + info.length)]
            guard let match = Constant.qualifierRegex.findFirst(in: data) else { return nil }
            return match.group(at: 2)
        }.first
        #endif
    }
}
