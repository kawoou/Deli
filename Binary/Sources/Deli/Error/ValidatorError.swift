//
//  ValidatorError.swift
//  Deli
//

enum ValidatorError: Error {
    case brokenLink
    case circularDependency
    
    var localizedDescription: String {
        switch self {
        case .brokenLink:
            return "There is an unregistered dependency."
        case .circularDependency:
            return "The circular dependency exists."
        }
    }
}

