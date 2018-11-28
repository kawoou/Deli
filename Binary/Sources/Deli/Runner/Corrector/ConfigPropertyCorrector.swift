//
//  ConfigPropertyCorrector.swift
//  deli
//
//  Created by Kawoou on 28/11/2018.
//

final class ConfigPropertyCorrector: Correctable {

    // MARK: - Private

    private let parser: Parser
    private let propertyParser: PropertyParser

    // MARK: - Public

    func correct(by results: [Results]) throws -> [Results] {
        return try results.map { result -> Results in
            guard let propertyResult = result as? ConfigPropertyResult else { return result }
            guard let info = parser.inheritanceList(result.instanceType).first else { return result }

            propertyResult.propertyValues = try propertyResult.propertyKeys.map {
                let path = "\(propertyResult.propertyTargetKey).\($0)"
                guard let property = try propertyParser.getProperty(path) else {
                    Logger.log(.error("Not found configuration property: \(path)", info.structure.getSourceLine(with: info.content)))
                    throw CorrectorError.notFoundConfigurationProperty
                }
                guard let safeProperty = property as? String else {
                    Logger.log(.error("Not found configuration property: \(path)", info.structure.getSourceLine(with: info.content)))
                    throw CorrectorError.notFoundConfigurationProperty
                }
                return safeProperty
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
