import Foundation

struct Friend {
    let id: String
    let name: String
    let age: Int
    let createdAt: Date

    init(id: String, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
        self.createdAt = Date()
    }
}
