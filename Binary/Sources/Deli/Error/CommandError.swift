//
//  CommandError.swift
//  Deli
//

enum CommandError: Error {
    case runner(Error)
    case notFoundLatestVersion
    case failedToLoadConfigFile
    case requiredOutputFile
    case unacceptableType
    case mustBeUsedWithProjectArguments
    case unknown

    var localizedDescription: String {
        switch self {
        case .runner(let error):
            return error.localizedDescription
        case .notFoundLatestVersion:
            return "Not found latest version on GitHub."
        case .failedToLoadConfigFile:
            return "Failed to load the config file."
        case .requiredOutputFile:
            return "Output file is required."
        case .unacceptableType:
            return "Unacceptable type."
        case .mustBeUsedWithProjectArguments:
            return "Must be used with project arguments."
        case .unknown:
            return "Unknown error."
        }
    }
}
