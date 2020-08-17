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
            projectName: "",
            fileName: "DeliFactory.swift",
            results: results,
            properties: properties
        )
    }

    init(projectName: String, fileName: String, results: [Results], properties: [String : Any]) {
        var newDict = [String: ResolveData.Dependency]()
        results
            .filter { !$0.isResolved }
            .forEach { result in
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
            projectName: projectName,
            referenceName: fileName
        )
    }
}
