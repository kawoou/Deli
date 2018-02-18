//
//  ViewModel.swift
//  GitHubSearch
//

import Deli
import RxCocoa
import RxSwift

class ViewModel: Autowired {
    
    // MARK: - Deli
    
    static let scope: Scope = .prototype
    
    // MARK: - Property
    
    let searchRequest = PublishSubject<SearchRequest>()
    let response = BehaviorRelay<SearchResponse?>(value: nil)
    
    // MARK: - Private
    
    private let disposeBag = DisposeBag()
    private let githubService: GitHubService
    
    // MARK: - Lifecycle
    
    required init(_ githubService: GitHubService) {
        self.githubService = githubService

        searchRequest
            .distinctUntilChanged()
            .flatMapLatest { githubService.search($0) }
            .scan(nil) { (old, new) in
                guard let old = old else { return new }
                guard old.query == new.query else { return new }
                return SearchResponse(
                    query: new.query,
                    repos: old.repos + new.repos,
                    nextPage: new.nextPage
                )
            }
            .bind(to: response)
            .disposed(by: disposeBag)
    }
}
