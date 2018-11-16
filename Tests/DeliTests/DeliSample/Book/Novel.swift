import Foundation

protocol Novel: Book {}

extension Novel {
    var category: String {
        return "Novel"
    }
}
