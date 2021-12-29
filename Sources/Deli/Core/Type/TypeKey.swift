//
//  TypeKey.swift
//  Deli
//

struct TypeKey {
    let type: ObjectIdentifier
    let qualifier: String

    private let hash: Int

    init(type: AnyClass, qualifier: String = "") {
        self.type = ObjectIdentifier(type)
        self.qualifier = qualifier

        hash = self.type.hashValue ^ qualifier.hashValue
    }

    @inline(__always)
    init<T>(type: T.Type, qualifier: String = "") {
	    self.type = ObjectIdentifier(type)
        self.qualifier = qualifier

        hash = self.type.hashValue ^ qualifier.hashValue
    }

    init(type: ObjectIdentifier, qualifier: String = "") {
        self.type = type
        self.qualifier = qualifier

        hash = type.hashValue ^ qualifier.hashValue
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
