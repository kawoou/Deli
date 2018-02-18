//
//  GeneratorError.swift
//  Deli
//

enum GeneratorError: Error {
    case pathError
    case unknown

    var localizedDescription: String {
        switch self {
        case .pathError:
            return "Path error."
        case .unknown:
            return "Unknown"
        }
    }
}
