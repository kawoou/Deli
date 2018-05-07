//
//  ParserError.swift
//  Deli
//

enum ParserError: Error {
    case constructorNotFound
    case constructorAmbiguous
    case injectorNotFound
    case injectorAmbiguous
    case scopeAmbiguous
    case qualifierAmbiguous
    case qualifierUnavailable
    case typeNotFound
    case emptyArguments
    case manyArguments
    case unavailableDeclaration
    case payloadNotFound
    case unknownName
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .constructorNotFound:
            return "Not found dependency constructor."
        case .constructorAmbiguous:
            return "Ambiguous dependency constructor."
        case .injectorNotFound:
            return "Not found dependency injector."
        case .injectorAmbiguous:
            return "Ambiguous dependency injector."
        case .scopeAmbiguous:
            return "Ambiguous scope property."
        case .qualifierAmbiguous:
            return "Ambiguous qualifier property."
        case .qualifierUnavailable:
            return "Unavailable qualifier value."
        case .typeNotFound:
            return "Not found dependency type."
        case .emptyArguments:
            return "The method required arguments."
        case .manyArguments:
            return "The method accepts only single argument."
        case .unavailableDeclaration:
            return "This declaration is not allowed."
        case .payloadNotFound:
            return "Not found payload type."
        case .unknownName:
            return "Unknown structure name."
        case .unknown:
            return "Unknown error."
        }
    }
}
