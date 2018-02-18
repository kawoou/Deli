//
//  SearchRequest.swift
//  GitHubSearch
//

struct SearchRequest {
    let query: String
    let page: Int
    
    init(query: String, page: Int) {
        self.query = query
        self.page = page
    }
}
extension SearchRequest: Equatable {
    static func ==(lhs: SearchRequest, rhs: SearchRequest) -> Bool {
        guard lhs.query == rhs.query else { return false }
        guard lhs.page == rhs.page else { return false }
        return true
    }
}
