import Foundation

protocol Science: Book {}

extension Science {
    var qualifier: String? {
        return "Science"
    }

    var category: String {
        return "Science"
    }
}
