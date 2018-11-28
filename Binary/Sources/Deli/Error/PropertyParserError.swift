//
//  PropertyParserError.swift
//  deli
//
//  Created by Kawoou on 28/11/2018.
//

enum PropertyParserError: Error {
    case propertyNotFound
    case propertyIsNotString
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
        case .propertyIsNotString:
            return "Property is not string value."
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
