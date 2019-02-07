//
//  ResolveGenerator.swift
//  Deli
//

import Yams

final class ResolveGenerator: Generator {

    // MARK: - Public

    func generate() throws -> String {
        let encoder = YAMLEncoder()
        return try encoder.encode(data)
    }

    // MARK: - Private

    private let data: ResolveData

    // MARK: - Lifecycle

    convenience init(results: [Results], properties: [String : Any]) {
        self.init(
            fileName: "DeliFactory.swift",
            results: results,
            properties: properties
        )
    }

    init(fileName: String, results: [Results], properties: [String : Any]) {
        var newDict = [String: ResolveData.Dependency]()
        results.forEach { result in
            let dependency = ResolveData.Dependency(result: result)

            if var oldValue = newDict[dependency.type] {
                oldValue.merging(dependency)
                newDict[dependency.type] = oldValue
            } else {
                newDict[dependency.type] = dependency
            }
        }

        data = ResolveData(
            dependency: Array(newDict.values).sorted { $0.type < $1.type },
            property: properties,
            referenceName: fileName
        )
    }
}

private extension ResolveData.DependencyTarget {
    init(dependency: Dependency) {
        type = dependency.name
        qualifier = dependency.qualifier
        qualifierBy = dependency.qualifierBy
    }
}
private extension ResolveData.Dependency {
    init(result: Results) {
        type = result.instanceType
        qualifier = result.qualifier
        isLazy = result.isLazy
        isFactory = result.isFactory
        isValueType = result.valueType
        dependencies = result.dependencies
            .map { ResolveData.DependencyTarget(dependency: $0) }
        linkType = Array(result.linkType)
    }

    mutating func merging(_ data: ResolveData.Dependency) {
        dependencies.append(contentsOf: data.dependencies)
        linkType.append(contentsOf: data.linkType)
    }
}
