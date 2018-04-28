//
//  CircularDependencyValidator.swift
//  Deli
//

import Foundation

final class CircularDependencyValidator: Validatable {

    // MARK: - Private

    let parser: Parser

    var travelInstance: Set<String> = Set()
    var chainStack: [String] = []

    var resultMap: [String: [Results]] = [:]

    private func testStack() throws {
        let stackSet = Set(chainStack)
        guard stackSet.count != chainStack.count else { return }

        #if swift(>=4.1)
        let isInnerLazy = stackSet
            .compactMap { resultMap[$0] }
            .flatMap { $0 }
            .reduce(false) { $0 || $1.isLazy }
        #else
        let isInnerLazy = stackSet
            .flatMap { resultMap[$0] }
            .flatMap { $0 }
            .reduce(false) { $0 || $1.isLazy }
        #endif

        guard isInnerLazy == false else { return }

        for chain in chainStack {
            let fileLine: String? = {
                guard let info = parser.inheritanceList(chain).first else { return nil }
                return info.structure.getSourceLine(with: info.content)
            }()
            Logger.log(.error("The circular dependency exists. (\(chainStack.joined(separator: " -> ")))", fileLine))
        }
        throw ValidatorError.circularDependency
    }

    private func recursiveFind(_ result: Results) throws {
        guard travelInstance.contains(result.instanceType) == false else { return }
        travelInstance.insert(result.instanceType)

        for dependency in result.dependencies {
            let fileLine: String? = {
                guard let lastName = chainStack.last else { return nil }
                guard let info = parser.inheritanceList(lastName).first else { return nil }
                return info.structure.getSourceLine(with: info.content)
            }()

            guard let results = resultMap[dependency.name] else {
                Logger.log(.error("`\(dependency.name)` is unregistered dependency. (\(chainStack.joined(separator: " -> ")))", fileLine))
                throw ValidatorError.brokenLink
            }
            let newResults: [Results] = {
                guard dependency.qualifier != "" else { return results }
                return results.filter { $0.qualifier ?? "" == dependency.qualifier }
            }()
            guard newResults.count > 0 else {
                Logger.log(.error("`\(dependency.name)(qualifier: \(dependency.qualifier))` is unregistered dependency. (\(chainStack.joined(separator: " -> ")))", fileLine))
                throw ValidatorError.brokenLink
            }

            for result in newResults {
                chainStack.append(result.instanceType)
                try recursiveFind(result)
                try testStack()
                chainStack.removeLast()
            }
        }
    }

    // MARK: - Public

    func validate(by results: [Results]) throws {
        /// Initlialize
        travelInstance.removeAll()
        chainStack.removeAll()
        resultMap.removeAll()

        for result in results {
            guard let list = resultMap[result.instanceType] else {
                resultMap[result.instanceType] = [result]
                continue
            }
            resultMap[result.instanceType] = list + [result]
        }
        for result in results {
            for link in result.linkType {
                guard let list = resultMap[link] else {
                    resultMap[link] = [result]
                    continue
                }
                resultMap[link] = list + [result]
            }
        }

        /// Finding
        for result in results {
            chainStack.append(result.instanceType)
            try recursiveFind(result)
            try testStack()
            chainStack.removeLast()
        }
    }

    // MARK: - Lifecycle

    required init(parser: Parser) {
        self.parser = parser
    }
}
