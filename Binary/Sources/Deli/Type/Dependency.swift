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
    enum DependencyRule {
        case `default`
        case payload
    }

    // MARK: - Property

    let parent: String
    let target: Structure?
    
    let name: String
    let type: DependencyType
    let rule: DependencyRule
    var qualifier: String
    let qualifierBy: String?

    // MARL: - Lifecycle

    init(parent: String, target: Structure?, name: String, type: DependencyType = .single, rule: DependencyRule = .default, qualifier: String = "", qualifierBy: String? = nil) {
        self.parent = parent
        self.target = target
        self.name = name
        self.type = type
        self.rule = rule
        self.qualifier = qualifier
        self.qualifierBy = qualifierBy
    }
}
extension Dependency: Hashable {
#if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(rule)
        hasher.combine(qualifier)
        hasher.combine(qualifierBy)
    }
#else
    var hashValue: Int {
        return name.hashValue ^ type.hashValue ^ rule.hashValue ^ qualifier.hashValue ^ qualifierBy.hashValue
    }
#endif

    static func ==(lhs: Dependency, rhs: Dependency) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.type == rhs.type else { return false }
        guard lhs.rule == rhs.rule else { return false }
        guard lhs.qualifier == rhs.qualifier else { return false }
        guard lhs.qualifierBy == rhs.qualifierBy else { return false }
        return true
    }
}
