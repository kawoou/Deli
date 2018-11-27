//
//  CommandLine+Argument.swift
//  Deli
//
//  Created by Kawoou on 27/11/2018.
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
