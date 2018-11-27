//
//  Generator.swift
//  Deli
//

import Foundation

protocol Generator {
    func generate() throws -> String

    init(results: [Results], properties: [String: Any])
}
