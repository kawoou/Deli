//
//  CorrectorError.swift
//  Deli
//

enum CorrectorError: Error {
    case implementationNotFound
    case ambiguousImplementation
    case notFoundConfigurationProperty
    
    var localizedDescription: String {
        switch self {
        case .implementationNotFound:
            return "Not found implementation logic on dependency."
        case .ambiguousImplementation:
            return "Ambiguous implementation logic on dependency."
        case .notFoundConfigurationProperty:
            return "Not found configuration property."
        }
    }
}
