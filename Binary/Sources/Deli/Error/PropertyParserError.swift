//
//  PropertyParserError.swift
//  Deli
//

enum PropertyParserError: Error {
    case propertyNotFound
    case pathNotFound

    case notStartedBracket
    case notEndedColon
    case notEndedBracket
    case notEmtpyKey
    case notMatchedColon

    var localizedDescription: String {
        switch self {
        case .propertyNotFound:
            return "Property not found in configuration property."
        case .pathNotFound:
            return "Path not found in configuration property."
        case .notStartedBracket:
            return "Not started bracket."
        case .notEndedColon:
            return "Not ended colon."
        case .notEndedBracket:
            return "Not ended bracket."
        case .notEmtpyKey:
            return "Key is not empty."
        case .notMatchedColon:
            return "Not matched colon."
        }
    }
}
