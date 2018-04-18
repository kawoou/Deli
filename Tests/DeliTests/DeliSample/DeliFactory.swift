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
            HarryPotter.self,
            resolver: {
                return HarryPotter()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
        context.register(
            NetworkManagerImpl.self,
            resolver: {
                return NetworkManagerImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(NetworkManager.self)
        context.register(
            COSMOS.self,
            resolver: {
                return COSMOS()
            },
            qualifier: "Science",
            scope: .singleton
        ).link(Book.self)
        context.register(
            AccountService.self,
            resolver: {
                let _AccountConfiguration = context.get(AccountConfiguration.self, qualifier: "")!
                return _AccountConfiguration.accountService() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        context.register(
            AccountConfiguration.self,
            resolver: {
                return AccountConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        context.register(
            MessageServiceImpl.self,
            resolver: {
                let _FriendService = context.get(FriendService.self, qualifier: "")!
                let _AccountService = context.get(AccountService.self, qualifier: "")!
                return MessageServiceImpl(_FriendService, _AccountService)
            },
            qualifier: "",
            scope: .singleton
        )
        context.register(
            TestViewModel.self,
            resolver: {
                let _AccountService = context.get(AccountService.self, qualifier: "")!
                let _FriendService = context.get(FriendService.self, qualifier: "")!
                return TestViewModel(_AccountService, _FriendService)
            },
            qualifier: "",
            scope: .prototype
        )
        context.register(
            LibraryService.self,
            resolver: {
                let _TestService = context.get(TestService.self, qualifier: "")!
                let _Book = context.get([Book].self, qualifier: "")
                return LibraryService(_TestService, _Book)
            },
            qualifier: "",
            scope: .singleton
        )
        context.register(
            TroisiemeHumanite.self,
            resolver: {
                return TroisiemeHumanite()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
        context.registerLazy(
            TestService.self,
            resolver: {
                return TestService()
            },
            injector: { instance in
                let _FriendServiceImpl = context.get(FriendServiceImpl.self, qualifier: "")!
                instance.inject(_FriendServiceImpl)
            },
            qualifier: "",
            scope: .singleton
        )
        context.register(
            FriendServiceImpl.self,
            resolver: {
                let _AccountService = context.get(AccountService.self, qualifier: "")!
                return FriendServiceImpl(_AccountService)
            },
            qualifier: "",
            scope: .singleton
        ).link(FriendService.self)

        self.context = context
    }
}