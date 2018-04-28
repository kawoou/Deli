//
//  GitHubService.swift
//  GitHubSearch
//

import Deli
import RxSwift

protocol GitHubService {
    func search(_ request: SearchRequest) -> Single<SearchResponse>
}
final class GitHubServiceImpl: GitHubService, Autowired {
    
    // MARK: - Constant
    
    private struct Constant {
        static let pageCount = 30
        
        static let searchURL = "https://api.github.com/search/repositories?q=%@&page=%d&per_page=\(pageCount)"
    }
    
    // MARK: - Public
    
    func search(_ request: SearchRequest) -> Single<SearchResponse> {
        let query = request.query
        let page = request.page

        let urlPath = String(format: Constant.searchURL, query, page)
        
        guard let url = URL(string: urlPath) else { return .just(.empty) }
        return networkManager.request(json: url)
            .map { json -> SearchResponse in
                guard let items = json["items"] as? [[String: Any]] else { return .empty }
                
                let repos = items.compactMap { $0["full_name"] as? String }
                
                guard repos.count < Constant.pageCount else {
                    return SearchResponse(query: query, repos: repos, nextPage: page + 1)
                }
                return SearchResponse(query: query, repos: repos, nextPage: nil)
            }
            .catchError { _ in .just(.empty) }
    }
    
    // MARK: - Private
    
    private let networkManager: NetworkManager
    
    // MARK: - Lifecycle
    
    required init(_ networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}
