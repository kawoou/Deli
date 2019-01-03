//
//  DeliFactory.swift
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        loadProperty([
            "environment": "dev",
            "server": [
                "method": "get",
                "port": "8080",
                "url": "http://dev.test.com"
            ]
        ])

        register(
            AccountConfiguration.self,
            resolver: {
                return AccountConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
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
            AlwaysModel.self,
            resolver: {
                return AlwaysModel()
            },
            qualifier: "",
            scope: .always
        )
        register(
            AngryRobotHead.self,
            resolver: {
                return AngryRobotHead()
            },
            qualifier: "angry",
            scope: .singleton
        )
        register(
            BlueRobotBody.self,
            resolver: {
                return BlueRobotBody()
            },
            qualifier: "blue",
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
            DeleteMethod.self,
            resolver: {
                return DeleteMethod()
            },
            qualifier: "delete",
            scope: .singleton
        )
        register(
            DevNetworkProvider.self,
            resolver: {
                return DevNetworkProvider()
            },
            qualifier: "dev",
            scope: .singleton
        ).link(NetworkProvider.self)
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
            FriendServiceImpl.self,
            resolver: {
                let _0 = context.get(AccountService.self, qualifier: "")!
                return FriendServiceImpl(_0)
            },
            qualifier: "",
            scope: .singleton
        ).link(FriendService.self)
        register(
            GetMethod.self,
            resolver: {
                return GetMethod()
            },
            qualifier: "get",
            scope: .singleton
        ).link(NetworkMethod.self)
        register(
            HappyRobotHead.self,
            resolver: {
                return HappyRobotHead()
            },
            qualifier: "happy",
            scope: .singleton
        ).link(RobotHead.self)
        register(
            HarryPotter.self,
            resolver: {
                return HarryPotter()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
        register(
            InjectPropertyTest.self,
            resolver: {
                return InjectPropertyTest()
            },
            qualifier: "",
            scope: .singleton
        )
        registerLazy(
            LazyAutowiredQualifier.self,
            resolver: {
                return LazyAutowiredQualifier()
            },
            injector: { instance in
                let _0 = context.get(TestService.self, qualifier: "qualifierTest")!
                instance.inject(qualifierTest: _0)
            },
            qualifier: "",
            scope: .singleton
        )
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
        register(
            PostMethod.self,
            resolver: {
                return PostMethod()
            },
            qualifier: "post",
            scope: .singleton
        )
        register(
            ProdNetworkProvider.self,
            resolver: {
                return ProdNetworkProvider()
            },
            qualifier: "prod",
            scope: .singleton
        )
        register(
            PropertyAutowired.self,
            resolver: {
                let _qualifier0 = context.getProperty("environment") as! String
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                return PropertyAutowired(_0)
            },
            qualifier: "",
            scope: .singleton
        )
        registerFactory(
            PropertyAutowiredFactory.self,
            resolver: { payload in
                let _qualifier0 = context.getProperty("environment") as! String
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                return PropertyAutowiredFactory(_0, payload: payload as! PropertyAutowiredFactoryPayload)
            },
            qualifier: ""
        )
        register(
            PropertyInject.self,
            resolver: {
                return PropertyInject()
            },
            qualifier: "",
            scope: .singleton
        )
        registerLazy(
            PropertyLazyAutowired.self,
            resolver: {
                return PropertyLazyAutowired()
            },
            injector: { instance in
                let _qualifier0 = context.getProperty("environment") as! String
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                instance.inject(_0)
            },
            qualifier: "",
            scope: .singleton
        )
        registerLazyFactory(
            PropertyLazyAutowiredFactory.self,
            resolver: { payload in
                return PropertyLazyAutowiredFactory(payload: payload as! PropertyLazyAutowiredFactoryPayload)
            },
            injector: { instance in
                let _qualifier0 = context.getProperty("environment") as! String
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                instance.inject(_0)
            },
            qualifier: ""
        )
        register(
            PutMethod.self,
            resolver: {
                return PutMethod()
            },
            qualifier: "put",
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
        registerFactory(
            Robot.self,
            resolver: { payload in
                
                return Robot(payload: payload as! RobotPayload)
            },
            qualifier: ""
        ).link(Robot.self)
        register(
            RobotFactory.self,
            resolver: {
                return RobotFactory()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            ServerConfig.self,
            resolver: {
                return ServerConfig(
                    method: context.getProperty("server.method") as! String,
                    url: context.getProperty("server.url") as! String,
                    port: context.getProperty("server.port") as! String
                )
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
        registerFactory(
            StructWithAutowiredFactory.self,
            resolver: { payload in
                let _0 = context.get(FriendService.self, qualifier: "")!
                return StructWithAutowiredFactory(_0, payload: payload as! StructPayload)
            },
            qualifier: ""
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
            TestNetworkProvider.self,
            resolver: {
                return TestNetworkProvider()
            },
            qualifier: "test",
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
            TroisiemeHumanite.self,
            resolver: {
                return TroisiemeHumanite()
            },
            qualifier: "Novel",
            scope: .singleton
        ).link(Book.self)
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