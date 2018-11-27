//
//  RawGenerator.swift
//  Deli
//

import Foundation

final class RawGenerator: Generator {
    
    // MARK: - Public
    
    func generate() throws -> String {
        return results
            .map { (result: Results) -> String in
                return result.description
            }
            .joined(separator: "\n\n")
    }
    
    // MARK: - Private
    
    private let results: [Results]
    private let properties: [String: Any]
    
    // MARK: - Lifecycle
    
    init(results: [Results], properties: [String: Any]) {
        self.results = results
        self.properties = properties
    }
}
