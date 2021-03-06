//
//  DeliFactory.swift
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        loadProperty([
            "boolean1": "true",
            "boolean2": "1",
            "environment": "dev",
            "int16": "32767",
            "int32": "2147483647",
            "int64": "9223372036854775807",
            "int8": "127",
            "server": [
                "method": "get",
                "port": "8080",
                "url": "http://dev.test.com"
            ],
            "uint16": "65535",
            "uint32": "4294967295",
            "uint64": "18446744073709551615",
            "uint8": "255"
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
                return parent.facebookAccountService()
            },
            qualifier: "facebook",
            scope: .singleton
        )
        register(
            AccountService.self,
            resolver: {
                let parent = context.get(AccountConfiguration.self, qualifier: "")!
                return parent.googleAccountService()
            },
            qualifier: "google",
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
                let _0 = context.get(AccountService.self, qualifier: "facebook")!
                return FriendInfoViewModel(facebook: _0, payload: payload as! FriendPayload)
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
                let _0 = context.get(AccountService.self, qualifier: "facebook")!
                return FriendServiceImpl(facebook: _0)
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
                let _1 = context.get(AccountService.self, qualifier: "facebook")!
                return MessageServiceImpl(_0, facebook: _1)
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NestedClass.NestedStruct.self,
            resolver: {
                return NestedClass.NestedStruct()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NestedStruct.NestedClass.self,
            resolver: {
                return NestedStruct.NestedClass()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NestedStruct.NestedClass.NestedStruct.NestedClass.self,
            resolver: {
                return NestedStruct.NestedClass.NestedStruct.NestedClass()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NestedTestClass.self,
            resolver: {
                let _0 = context.get(NestedClass.NestedStruct.self, qualifier: "")!
                let _1 = context.get(NestedStruct.NestedClass.self, qualifier: "")!
                let _2 = context.get(NestedStruct.NestedClass.NestedStruct.NestedClass.self, qualifier: "")!
                return NestedTestClass(_0, _1, _2)
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
                let _qualifier0 = context.getProperty("environment", type: String.self)!
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                return PropertyAutowired(_0)
            },
            qualifier: "",
            scope: .singleton
        )
        registerFactory(
            PropertyAutowiredFactory.self,
            resolver: { payload in
                let _qualifier0 = context.getProperty("environment", type: String.self)!
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
                let _qualifier0 = context.getProperty("environment", type: String.self)!
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
                let _qualifier0 = context.getProperty("environment", type: String.self)!
                let _0 = context.get(NetworkProvider.self, qualifier: _qualifier0)!
                instance.inject(_0)
            },
            qualifier: ""
        )
        register(
            PropertyWrapperTest1.self,
            resolver: {
                let _0 = context.get(AccountService.self, qualifier: "google")!
                let _1 = context.get(FriendService.self, qualifier: "")!
                return PropertyWrapperTest1(google: _0, _1)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            PropertyWrapperTest3.self,
            resolver: {
                return PropertyWrapperTest3()
            },
            qualifier: "",
            scope: .prototype
        ).link(PropertyWrapperTest2.self)
        register(
            PropertyWrapperTest4.self,
            resolver: {
                return PropertyWrapperTest4()
            },
            qualifier: "",
            scope: .prototype
        ).link(PropertyWrapperTest2.self)
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
                    method: context.getProperty("server.method", type: String.self),
                    url: context.getProperty("server.url", type: String.self)!,
                    port: context.getProperty("server.port", type: Int.self)!
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
                let _0 = context.get(AccountService.self, qualifier: "facebook")!
                let _1 = context.get(FriendService.self, qualifier: "")!
                return TestViewModel(facebook: _0, _1)
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
                let _0 = context.get(AccountService.self, qualifier: "facebook")!
                return UserViewModel(facebook: _0, payload: payload as! UserPayload)
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