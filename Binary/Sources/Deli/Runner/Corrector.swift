//
//  Corrector.swift
//  Deli
//

import Foundation

final class Corrector: Runnable {

    // MARK: - Property

    let moduleList: [Correctable]

    // MARK: - Public

    func run(_ results: [Results]) throws -> [Results] {
        var newResults = results
        for module in moduleList {
            newResults = try module.correct(by: newResults)
        }
        return newResults
    }

    // MARK: - Lifecycle

    required init(_ modules: [Correctable]) {
        moduleList = modules
    }
}
