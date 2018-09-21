//
//  GitHubFactory.swift
//  Auto generated code.
//

import Deli

final class GitHubFactory: ModuleFactory {
    override func load(context: AppContext) {
        register(
            ViewModel.self,
            resolver: {
                let _GitHubService = context.get(GitHubService.self, qualifier: "")!
                return ViewModel(_GitHubService)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            NetworkManagerImpl.self,
            resolver: {
                return NetworkManagerImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(NetworkManager.self)
        register(
            GitHubServiceImpl.self,
            resolver: {
                let _NetworkManager = context.get(NetworkManager.self, qualifier: "")!
                return GitHubServiceImpl(_NetworkManager)
            },
            qualifier: "",
            scope: .singleton
        ).link(GitHubService.self)
    }
}