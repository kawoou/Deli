import Foundation

struct Novel: Book {
    static var qualifier: String? {
        return "Novel"
    }

    var category: String {
        return "Novel"
    }
}
