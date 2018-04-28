//
//  Deli Factory
//  Auto generated code.
//

import Deli

final class DeliFactory {
    let context: AppContextType

    init() {
        let context = AppContext.shared
        context.register(
            ViewModel.self,
            resolver: {
                let _GitHubService = context.get(GitHubService.self, qualifier: "")!
                return ViewModel(_GitHubService)
            },
            qualifier: "",
            scope: .prototype
        )
        context.register(
            NetworkManagerImpl.self,
            resolver: {
                return NetworkManagerImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(NetworkManager.self)
        context.register(
            GitHubServiceImpl.self,
            resolver: {
                let _NetworkManager = context.get(NetworkManager.self, qualifier: "")!
                return GitHubServiceImpl(_NetworkManager)
            },
            qualifier: "",
            scope: .singleton
        ).link(GitHubService.self)

        self.context = context
    }
}