//
//  ValidatorError.swift
//  Deli
//

enum ValidatorError: Error {
    case brokenLink
    case circularDependency
    case factoryReference
    
    var localizedDescription: String {
        switch self {
        case .brokenLink:
            return "There is an unregistered dependency."
        case .circularDependency:
            return "The circular dependency exists."
        case .factoryReference:
            return "The Factory type cannot be used as Dependency."
        }
    }
}

