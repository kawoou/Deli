//
//  DependencyTree.swift
//  Deli
//

import Foundation

final class DependencyTree {

    // MARK: - Private

    private var dependencyMap = [String: Set<String>]()

    private func findRecursive(_ target: String, travelInstance: inout Set<String>) -> Bool {
        guard !travelInstance.contains(target) else { return false }
        travelInstance.insert(target)

        let dependencies = Array(dependencyMap[target] ?? Set())
        for dependency in dependencies {
            guard findRecursive(dependency, travelInstance: &travelInstance) else { return false }
        }

        travelInstance.remove(target)

        return true
    }

    // MARK: - Public

    func append(_ target: String) {
        if dependencyMap[target] == nil {
            dependencyMap[target] = Set()
        }
    }

    func push(_ target: String, dependsOn dependency: String) {
        if var list = dependencyMap[target] {
            list.insert(dependency)
            dependencyMap[target] = list
        } else {
            dependencyMap[target] = Set(arrayLiteral: dependency)
        }

        if dependencyMap[dependency] == nil {
            dependencyMap[dependency] = Set()
        }
    }

    func pop() -> String? {
        guard let element = dependencyMap.first(where: { $0.value.isEmpty }) else { return nil }

        dependencyMap.removeValue(forKey: element.key)
        dependencyMap = dependencyMap.mapValues { list in
            var list = list
            list.remove(element.key)
            return list
        }

        return element.key
    }

    func validate() -> Bool {
        var travelInstance: Set<String> = Set()

        for dependency in Array(dependencyMap.keys) {
            guard findRecursive(dependency, travelInstance: &travelInstance) else { return false }
        }

        return true
    }

}
