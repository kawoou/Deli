//
//  ResolveLinkerResult.swift
//  Deli
//

final class ResolveLinkerResult: Results {
    let valueType: Bool = false
    let isLazy: Bool = false
    let isFactory: Bool = false
    let isRegister: Bool = false
    let isResolved: Bool = false
    let instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency] = []
    var instanceDependency: [Dependency] = []
    var inheritanceList: [String] = []
    var imports: [String] = []
    var module: String?
    var linkType: Set<String>

    init(_ result: Results, linkType: String) {
        self.instanceType = result.instanceType
        self.qualifier = result.qualifier
        self.module = result.module
        self.linkType = Set([linkType])
    }
}
