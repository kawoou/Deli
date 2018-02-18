//
//  CommandError.swift
//  Deli
//

enum CommandError: Error {
    case runner(Error)
    case failedToLoadConfigFile
    case requiredOutputFile
    case unacceptableType
    case unknown

    var localizedDescription: String {
        switch self {
        case .runner(let error):
            return error.localizedDescription
        case .failedToLoadConfigFile:
            return "Failed to load the config file."
        case .requiredOutputFile:
            return "Output file is required."
        case .unacceptableType:
            return "Unacceptable type."
        case .unknown:
            return "Unknown error."
        }
    }
}
