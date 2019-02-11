//
//  RawGenerator.swift
//  Deli
//

import Foundation

final class RawGenerator: Generator {
    
    // MARK: - Public
    
    func generate() throws -> String {
        return results
            .filter { !$0.isResolved }
            .map { $0.description }
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
