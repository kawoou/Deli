//
//  InjectProtocolResult.swift
//  Deli
//

final class InjectProtocolResult: Results {
    var isLazy: Bool { return false }
    var isFactory: Bool { return false }
    var isRegister: Bool { return false }
    var instanceType: String
    var scope: String? = nil
    var qualifier: String? = nil
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()

    init(_ instanceType: String, _ dependencies: [Dependency]) {
        self.instanceType = instanceType
        self.dependencies = dependencies
    }
}
