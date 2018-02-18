//
//  InjectProtocolResult.swift
//  Deli
//

final class InjectProtocolResult: Results {
    var isLazy: Bool { return false }
    var instanceType: String
    var scope: String? { return nil }
    var qualifier: String? { return nil }
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()

    init(_ instanceType: String, _ dependencies: [Dependency]) {
        self.instanceType = instanceType
        self.dependencies = dependencies
    }
}
