//
//  ParserSupport.swift
//  Deli
//

import SourceKittenFramework

private struct Constant {
    static let scopeName = "scope"
    static let scopeRegex = "\(scopeName)(:[^=]*)?[\\s]*=[\\s]*([^\\s]+)".r!
    static let scopeClosureRegex = "\(scopeName)[\\s]*:[\\s]*(Deli\\.)?Scope[^\\{]*\\{[\\s]*return[\\s]+([^\\s]*)[\\s]*\\}".r!
    
    static let qualifierName = "qualifier"
    static let qualifierRegex = "\(qualifierName)(:[^=]*)?[\\s]*=[\\s]*\"([^\"]*)\"".r!
    static let qualifierClosureRegex = "\(qualifierName)[\\s]*:[\\s]*String\\?[^\\{]*\\{[\\s]*return[\\s]+\"([^\"]*)\"[\\s]*\\}".r!

    static let commentRegex = "\\/\\*([^\\*]+)\\*\\/".r!
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
        for scope in scopeList {
            Logger.log(.error("Ambiguous `\(name)` scope property.", scope.getSourceLine(with: fileContent)))
        }
        throw ParserError.scopeAmbiguous
    }

    return scopeList
        .compactMap { info in
            guard let data = fileContent.utf8[Int(info.offset)..<Int(info.offset + info.length)] else {
                return nil
            }
            if let match = Constant.scopeRegex.findFirst(in: data) {
                return match.group(at: 2)
            }
            if let match = Constant.scopeClosureRegex.findFirst(in: data) {
                return match.group(at: 2)
            }
            return nil
        }
        .first
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
        for qualifier in qualifierList {
            Logger.log(.error("Ambiguous `\(name)` qualifier property.", qualifier.getSourceLine(with: fileContent)))
        }
        throw ParserError.qualifierAmbiguous
    }

    return qualifierList
        .compactMap { info in
            guard let data = fileContent.utf8[Int(info.offset)..<Int(info.offset + info.length)] else {
                return nil
            }
            if let match = Constant.qualifierRegex.findFirst(in: data) {
                return match.group(at: 2)
            }
            if let match = Constant.qualifierClosureRegex.findFirst(in: data) {
                return match.group(at: 1)
            }
            return nil
        }
        .first
}
func parseQualifierBy(_ source: Structure, fileContent: String) throws -> String? {
    let range = Int(source.offset)..<Int(source.offset + source.length)
    guard let content = fileContent.utf8[range] else { return nil }
    guard let match = Constant.commentRegex.findFirst(in: content) else { return nil }
    return match.group(at: 1)
}
