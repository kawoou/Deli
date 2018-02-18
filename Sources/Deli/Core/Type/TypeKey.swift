//
//  TypeKey.swift
//  Deli
//

struct TypeKey {
    let type: Any.Type
    let qualifier: String

    private let hash: Int

    init(type: Any.Type, qualifier: String) {
	    self.type = type
        self.qualifier = qualifier

	    hash = ObjectIdentifier(type).hashValue ^ qualifier.hashValue
    }
}
extension TypeKey: Hashable {
    var hashValue: Int {
	    return hash
    }
}
extension TypeKey: Equatable {
    static func ==(lhs: TypeKey, rhs: TypeKey) -> Bool {
	    guard lhs.type == rhs.type else { return false }
	    guard lhs.qualifier == rhs.qualifier else { return false }
	    return true
    }
}
