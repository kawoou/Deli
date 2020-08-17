//
//  TypeKey.swift
//  Deli
//

struct TypeKey {
    let type: Any.Type
    let qualifier: String

    private let hash: Int

    init(type: Any.Type, qualifier: String = "") {
	    self.type = type
        self.qualifier = qualifier

	    hash = ObjectIdentifier(type).hashValue ^ qualifier.hashValue
    }
}
extension TypeKey: Hashable {
    #if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    #else
    var hashValue: Int {
	    return hash
    }
    #endif
}
extension TypeKey: Equatable {
    static func ==(lhs: TypeKey, rhs: TypeKey) -> Bool {
	    guard lhs.type == rhs.type else { return false }
	    guard lhs.qualifier == rhs.qualifier else { return false }
	    return true
    }
}
