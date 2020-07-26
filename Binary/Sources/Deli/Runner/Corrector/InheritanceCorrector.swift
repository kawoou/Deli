//
//  InheritanceCorrector.swift
//  Deli
//

import Foundation

final class InheritanceCorrector: Correctable {

    // MARK: - Private

    private let parser: Parser

    // MARK: - Public

    func correct(by results: [Results]) throws -> [Results] {
        return results.map { result -> Results in
            if result.inheritanceList.isEmpty {
                result.inheritanceList = parser.inheritanceList(result.instanceType).map { $0.name }
            }
            return result
        }
    }

    // MARK: - Lifecycle

    init(parser: Parser) {
        self.parser = parser
    }
}
