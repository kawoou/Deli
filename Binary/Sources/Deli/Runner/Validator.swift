//
//  Validator.swift
//  Deli
//

import Foundation

final class Validator: Runnable {

    // MARK: - Property
    
    let moduleList: [Validatable]
    
    // MARK: - Public

    func run(_ results: [Results]) throws -> [Results] {
        for module in moduleList {
            try module.validate(by: results)
        }
        return results
    }
    
    // MARK: - Lifecycle
    
    required init(_ modules: [Validatable]) {
        moduleList = modules
    }
}
