//
//  ConfigPropertyCorrector.swift
//  Deli
//

import Foundation

final class ConfigPropertyCorrector: Correctable {

    // MARK: - Private

    private let parser: Parser
    private let propertyParser: PropertyParser

    // MARK: - Public

    func correct(by results: [Results]) throws -> [Results] {
        return try results.map { result -> Results in
            guard !result.isResolved else { return result }
            guard let propertyResult = result as? ConfigPropertyResult else { return result }
            guard let info = parser.inheritanceList(result.instanceType).first else { return result }

            try propertyResult.propertyInfos
                .filter { !$0.isOptional }
                .map { "\(propertyResult.propertyTargetKey).\($0.name)" }
                .forEach { path in
                    if try propertyParser.getProperty(path) == nil {
                        Logger.log(.error("Not found configuration property: \(path)", info.structure.getSourceLine(with: info.content)))
                        throw CorrectorError.notFoundConfigurationProperty
                    }
                }

            return result
        }
    }

    // MARK: - Lifecycle

    init(parser: Parser, propertyParser: PropertyParser) {
        self.parser = parser
        self.propertyParser = propertyParser
    }
}
