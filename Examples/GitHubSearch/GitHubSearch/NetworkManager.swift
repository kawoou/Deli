//
//  NetworkManager.swift
//  GitHubSearch
//

import Deli
import RxSwift
import RxOptional

protocol NetworkManager {
    func request(json url: URL) -> Single<[String: Any]>
}

final class NetworkManagerImpl: NetworkManager, Component {
    
    // MARK: - Public
    
    func request(json url: URL) -> Single<[String: Any]> {
        return URLSession.shared.rx.json(url: url)
            .map { $0 as? [String: Any] }
            .errorOnNil()
            .asSingle()
    }
    
    // MARK: - Lifecycle
    
    init() {}
}
