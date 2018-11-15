import Foundation

protocol Novel: Book {}

extension Novel {
    var qualifier: String? {
        return "Novel"
    }

    var category: String {
        return "Novel"
    }
}
