//
//  SearchResponse.swift
//  GitHubSearch
//

struct SearchResponse {
    static var empty: SearchResponse {
        return SearchResponse(query: "", repos: [], nextPage: nil)
    }

    let query: String
    let repos: [String]
    let nextPage: Int?
    
    init(query: String, repos: [String], nextPage: Int?) {
        self.query = query
        self.repos = repos
        self.nextPage = nextPage
    }
}
