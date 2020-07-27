//
//  GitHubFactory.swift
//  Auto generated code.
//

import Deli

// swiftlint:disable all
final class GitHubFactory: ModuleFactory {
    override func load(context: AppContext) {
        context.loadProperty([:])

        register(
            GitHubServiceImpl.self,
            resolver: {
                let _0 = context.get(NetworkManager.self, qualifier: "")!
                return GitHubServiceImpl(_0)
            },
            qualifier: "",
            scope: .singleton
        ).link(GitHubService.self)
        register(
            NetworkManagerImpl.self,
            resolver: {
                return NetworkManagerImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(NetworkManager.self)
        register(
            ViewModel.self,
            resolver: {
                let _0 = context.get(GitHubService.self, qualifier: "")!
                return ViewModel(_0)
            },
            qualifier: "",
            scope: .prototype
        )
    }
}