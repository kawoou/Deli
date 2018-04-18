//
//  NotImplementCorrector.swift
//  Deli
//

final class NotImplementCorrector: Correctable {

    // MARK: - Private

    private let parser: Parser

    // MARK: - Public

    func correct(by results: [Results]) throws -> [Results] {
        /// Dependency dictionary
        var resultMap = [Dependency: Results]()

        /// All dependency list
        var totalList = Set<Dependency>()

        for result in results {
            let instanceDependency = Dependency(name: result.instanceType)
            resultMap[instanceDependency] = result

            totalList.insert(instanceDependency)
            result.dependencies.forEach { totalList.insert($0) }
        }

        /// Correction
        try totalList
            .filter { resultMap[$0] == nil }
            .forEach { dependency in
                let correctList = results
                    .filter {
                        return parser.inheritanceList($0.instanceType)
                            .map { $0.name }
                            .contains(dependency.name)
                    }
                    .filter { result in
                        guard dependency.qualifier != "" else { return true }
                        return (result.qualifier ?? "") == dependency.qualifier
                    }

                guard correctList.count > 0 else {
                    Logger.log(.error("Not found implementation on `\(dependency.name)(qualifier: \"\(dependency.qualifier)\")`."))
                    throw CorrectorError.implementationNotFound
                }
                guard dependency.type != .single || correctList.count == 1 else {
                    let ambiguousNames = correctList.map { $0.instanceType }.joined(separator: ", ")
                    Logger.log(.error("Ambiguous implementation on `\(dependency.name)` (\(ambiguousNames))"))
                    throw CorrectorError.ambiguousImplementation
                }
                correctList.forEach { $0.linkType.insert(dependency.name) }
            }

        return results
    }

    // MARK: - Lifecycle

    required init(parser: Parser) {
        self.parser = parser
    }
}
