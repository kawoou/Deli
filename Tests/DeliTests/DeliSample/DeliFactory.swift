//
//  DeliFactory.swift
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        register(
            AccountService.self,
            resolver: {
                let parent = context.get(AccountConfiguration.self, qualifier: "")!
                return parent.accountService()
            },
            qualifier: "facebook",
            scope: .singleton
        ).link(AccountService.self)
        register(
            AccountConfiguration.self,
            resolver: {
                return AccountConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            COSMOS.self,
            resolver: {
                return COSMOS()
            },
            qualifier: "Science",
            scope: .singleton
        ).link(Book.self)
        register(
            HarryPotter.self,
            resolver: {
                return HarryPotter()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
        register(
            TroisiemeHumanite.self,
            resolver: {
                return TroisiemeHumanite()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
        registerLazyFactory(
            FactoryTest.self,
            resolver: { payload in
                return FactoryTest(payload: payload as! TestPayload)
            },
            injector: { instance in
                let _0 = context.get(AccountService.self, qualifier: "facebook")!
                instance.inject(facebook: _0)
            },
            qualifier: ""
        ).link(FactoryTest.self)
        registerFactory(
            FriendInfoViewModel.self,
            resolver: { payload in
                let _0 = context.get(AccountService.self, qualifier: "")!
                return FriendInfoViewModel(_0, payload: payload as! FriendPayload)
            },
            qualifier: ""
        ).link(FriendInfoViewModel.self)
        registerFactory(
            StructWithAutowiredFactory.self,
            resolver: { payload in
                let _0 = context.get(FriendService.self, qualifier: "")!
                return StructWithAutowiredFactory(_0, payload: payload as! StructPayload)
            },
            qualifier: ""
        )
        register(
            FriendListViewModel.self,
            resolver: {
                let _0 = context.get(FriendService.self, qualifier: "")!
                return FriendListViewModel(_0)
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            StructWithComponent.self,
            resolver: {
                return StructWithComponent()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            FriendServiceImpl.self,
            resolver: {
                let _0 = context.get(AccountService.self, qualifier: "")!
                return FriendServiceImpl(_0)
            },
            qualifier: "",
            scope: .singleton
        ).link(FriendService.self)
        register(
            LibraryService.self,
            resolver: {
                let _0 = context.get(TestService.self, qualifier: "qualifierTest")!
                let _1 = context.get([Book].self, qualifier: "")
                return LibraryService(qualifierTest: _0, _1)
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            MessageServiceImpl.self,
            resolver: {
                let _0 = context.get(FriendService.self, qualifier: "")!
                let _1 = context.get(AccountService.self, qualifier: "")!
                return MessageServiceImpl(_0, _1)
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NetworkManagerImpl.self,
            resolver: {
                return NetworkManagerImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(NetworkManager.self)
        registerFactory(
            Robot.self,
            resolver: { payload in
                
                return Robot(payload: payload as! RobotPayload)
            },
            qualifier: ""
        ).link(Robot.self)
        register(
            BlueRobotBody.self,
            resolver: {
                return BlueRobotBody()
            },
            qualifier: "blue",
            scope: .singleton
        )
        register(
            RedRobotBody.self,
            resolver: {
                return RedRobotBody()
            },
            qualifier: "red",
            scope: .singleton
        ).link(RobotBody.self)
        register(
            RobotFactory.self,
            resolver: {
                return RobotFactory()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            HappyRobotHead.self,
            resolver: {
                return HappyRobotHead()
            },
            qualifier: "happy",
            scope: .singleton
        ).link(RobotHead.self)
        register(
            AngryRobotHead.self,
            resolver: {
                return AngryRobotHead()
            },
            qualifier: "angry",
            scope: .singleton
        )
        registerLazy(
            TestService.self,
            resolver: {
                return TestService()
            },
            injector: { instance in
                let _0 = context.get(FriendServiceImpl.self, qualifier: "")!
                instance.inject(_0)
            },
            qualifier: "qualifierTest",
            scope: .singleton
        )
        register(
            TestViewModel.self,
            resolver: {
                let _0 = context.get(AccountService.self, qualifier: "")!
                let _1 = context.get(FriendService.self, qualifier: "")!
                return TestViewModel(_0, _1)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            StructWithAutowired.self,
            resolver: {
                let _0 = context.get(FriendService.self, qualifier: "")!
                return StructWithAutowired(_0)
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            UnicodeTest.self,
            resolver: {
                let _0 = context.get(FriendService.self, qualifier: "")!
                let _1 = context.get(LibraryService.self, qualifier: "")!
                return UnicodeTest(_0, _1)
            },
            qualifier: "",
            scope: .singleton
        )
        registerFactory(
            UserViewModel.self,
            resolver: { payload in
                let _0 = context.get(AccountService.self, qualifier: "")!
                return UserViewModel(_0, payload: payload as! UserPayload)
            },
            qualifier: ""
        ).link(UserViewModel.self)
        register(
            WeakViewModel.self,
            resolver: {
                return WeakViewModel()
            },
            qualifier: "",
            scope: .weak
        )
    }
}