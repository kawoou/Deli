//
//  ContainerError.swift
//  Deli
//

enum ContainerError: Error {
    case ambiguousComponent
    case unregistered

    var localizedDescription: String {
        switch self {
        case .ambiguousComponent:
            return "Ambiguous component: "

        case .unregistered:
            return "Unregistered component: "
        }
    }
}
