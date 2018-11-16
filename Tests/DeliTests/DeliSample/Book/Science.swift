import Foundation

protocol Science: Book {}

extension Science {
    var category: String {
        return "Science"
    }
}
