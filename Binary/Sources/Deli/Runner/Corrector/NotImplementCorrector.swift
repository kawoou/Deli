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
            let instanceDependency = Dependency(
                parent: result.instanceType,
                target: result.dependencies.first?.target,
                name: result.instanceType,
                qualifier: result.qualifier ?? ""
            )
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
                        let list = parser.inheritanceList($0.instanceType)
                        return (list.flatMap { $0.types } + list.map { $0.name })
                            .contains(dependency.name)
                    }
                    .filter { result in
                        guard dependency.qualifier != "" else { return true }
                        return (result.qualifier ?? "") == dependency.qualifier
                    }
                    .filter { $0.isRegister }

                let fileLine: String? = {
                    guard let targetInfo = dependency.target else {
                        guard let info = parser.inheritanceList(dependency.name).first else { return nil }
                        return info.structure.getSourceLine(with: info.content)
                    }
                    
                    guard let info = parser.inheritanceList(dependency.parent).first else { return nil }
                    return targetInfo.getSourceLine(with: info.content)
                }()
                guard correctList.count > 0 else {
                    Logger.log(.error("Not found implementation on `\(dependency.name)` with qualifier `\(dependency.qualifier)`.", fileLine))
                    throw CorrectorError.implementationNotFound
                }
                guard dependency.type != .single || correctList.count == 1 else {
                    let ambiguousNames = correctList
                        .map { $0.instanceType }
                        .joined(separator: ", ")
                    Logger.log(.error("Ambiguous implementation on `\(dependency.name)` (\(ambiguousNames))", fileLine))
                    throw CorrectorError.ambiguousImplementation
                }
                correctList.forEach { $0.linkType.insert(dependency.name) }
            }

        return results
    }

    // MARK: - Lifecycle

    init(parser: Parser) {
        self.parser = parser
    }
}
