//
//  Dependency.swift
//  Deli
//

struct Dependency {

    // MARK: - Enumerable

    enum DependencyType {
        case single
        case array
    }

    // MARK: - Property

    let name: String
    let type: DependencyType
    let qualifier: String

    // MARL: - Lifecycle

    init(name: String, type: DependencyType = .single, qualifier: String = "") {
        self.name = name
        self.type = type
        self.qualifier = qualifier
    }
}
extension Dependency: Hashable {
    var hashValue: Int {
        return name.hashValue ^ type.hashValue ^ qualifier.hashValue
    }

    static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.type == rhs.type else { return false }
        guard lhs.qualifier == rhs.qualifier else { return false }
        return true
    }
}
