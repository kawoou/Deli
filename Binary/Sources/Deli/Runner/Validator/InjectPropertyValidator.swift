//
//  InjectPropertyValidator.swift
//  Deli
//

final class InjectPropertyValidator: Validatable {

    // MARK: - Private

    let parser: Parser
    let propertyParser: PropertyParser

    // MARK: - Public

    func validate(by results: [Results]) throws {
        for result in results {
            guard let propertyResult = result as? InjectPropertyResult else { continue }
            guard let info = parser.inheritanceList(result.instanceType).first else { continue }

            for path in propertyResult.propertyKeys {
                guard try propertyParser.getProperty(path) != nil else {
                    Logger.log(.error("Not found configuration property: \(path)", info.structure.getSourceLine(with: info.content)))
                    throw CorrectorError.notFoundConfigurationProperty
                }
            }
        }
    }

    // MARK: - Lifecycle

    init(parser: Parser, propertyParser: PropertyParser) {
        self.parser = parser
        self.propertyParser = propertyParser
    }
}
