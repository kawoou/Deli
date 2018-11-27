//
//  ContainerError.swift
//  Deli
//

enum ContainerError: Error {
    case ambiguousComponent
    case unregistered

    case notStartedBracket
    case notEndedColon
    case notEndedBracket
    case notEmtpyKey
}
