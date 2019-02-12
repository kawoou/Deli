//
//  QualifierByCorrector.swift
//  Deli
//

import Foundation

final class QualifierByCorrector: Correctable {

    // MARK: - Private

    private let parser: Parser
    private let propertyParser: PropertyParser

    private func correctDependency(_ dependency: Dependency, info: InheritanceInfo) throws -> Dependency {
        var dependency = dependency

        guard let qualifierBy = dependency.qualifierBy else { return dependency }
        do {
            guard let property = try propertyParser.getProperty(qualifierBy) else {
                Logger.log(.error("Property not found in configuration property(\(qualifierBy))", info.structure.getSourceLine(with: info.content)))
                throw PropertyParserError.propertyNotFound
            }
            if property is NSNull {
                dependency.qualifier = ""
            } else {
                dependency.qualifier = "\(property)"
            }
        } catch {
            Logger.log(.error("Path not found in configuration property(\(qualifierBy))", info.structure.getSourceLine(with: info.content)))
            throw PropertyParserError.pathNotFound
        }
        return dependency
    }

    // MARK: - Public

    func correct(by results: [Results]) throws -> [Results] {
        return try results.map { result -> Results in
            guard !result.isResolved else { return result }
            guard let info = parser.inheritanceList(result.instanceType).first else { return result }

            result.dependencies = try result.dependencies
                .map { try correctDependency($0, info: info) }
            result.instanceDependency = try result.instanceDependency
                .map { try correctDependency($0, info: info) }

            return result
        }
    }

    // MARK: - Lifecycle

    init(parser: Parser, propertyParser: PropertyParser) {
        self.parser = parser
        self.propertyParser = propertyParser
    }

}
