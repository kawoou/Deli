//
//  ResolveDataSupport.swift
//  Deli
//

extension ResolveData.DependencyTarget {
    init(dependency: Dependency) {
        type = dependency.name
        qualifier = dependency.qualifier
        qualifierBy = dependency.qualifierBy
    }
}

extension ResolveData.Dependency {
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
