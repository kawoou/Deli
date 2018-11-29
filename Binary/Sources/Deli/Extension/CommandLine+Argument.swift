//
//  CommandLine+Argument.swift
//  Deli
//

import Foundation

extension CommandLine {
    static func get(forKey key: String) -> [String] {
        let newKey = "--\(key)"
        var isNextProperty = false
        var properties: [String] = []
        for argument in arguments {
            guard isNextProperty else {
                if argument.trimmingCharacters(in: .whitespacesAndNewlines) == newKey {
                    isNextProperty = true
                }
                continue
            }

            isNextProperty = false
            properties.append(argument)
        }
        return properties
    }
}
