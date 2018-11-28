//
//  DeliSpec.swift
//  DeliTests
//

import XCTest
import Quick
import Nimble

@testable import Deli

func address(_ object: UnsafeRawPointer) -> Int {
    return Int(bitPattern: object)
}

class DeliSpec: QuickSpec, Inject {
    override func spec() {
        super.spec()
        
        var appContext: AppContext!
        
        beforeEach {
            appContext = AppContext.shared
        }
        afterEach {
            appContext.reset()
            appContext.unloadAll()
        }
        describe("Deli's") {
            beforeEach {
                appContext.load([
                    DeliFactory.self
                ])
            }
            context("when inject with qualifier") {
                var sut: [Book] = []

                beforeEach {
                    sut = appContext.get([Book].self, qualifier: "Novel")
                }
                it("sut's qualifier should equal to 'Novel'") {
                    expect(sut.filter { $0.qualifier != "Novel" }.count) == 0
                }
            }
            context("when inject with payload") {
                context("test case 1") {
                    var sut1: TestView2!
                    var sut2: TestView3!
                    
                    beforeEach {
                        sut1 = TestView2()
                        sut2 = TestView3()
                    }
                    it("sut's parameter should equal to user specific payload") {
                        expect(sut1.viewModel.userID) == "UserID"
                        expect(sut2.test.test1) == false
                        expect(sut2.test.test2) == [1, 2, 3, 4, 5]
                    }
                }
                context("test case 2") {
                    var friendService: FriendService!
                    var testView3: TestView3!
                    
                    var friend1: FriendInfoViewModel?
                    var friend2: FriendInfoViewModel?
                    var friend3: FriendInfoViewModel?
                    
                    beforeEach {
                        friendService = appContext.get(FriendService.self)
                        testView3 = TestView3()
                        
                        friend1 = testView3.viewModel.generateInfo(by: "test1")
                        friend2 = testView3.viewModel.generateInfo(by: "test2")
                        friend3 = testView3.viewModel.generateInfo(by: "test3")
                    }
                    it("name of friend1 should equal to name of result that called getFriend('test1') in friendService") {
                        expect(friend1?.name) == friendService.getFriend(by: "test1")?.name
                    }
                    it("name of friend2 should equal to name of result that called getFriend('test2') in friendService") {
                        expect(friend2?.name) == friendService.getFriend(by: "test2")?.name
                    }
                    it("name of friend3 should equal to name of result that called getFriend('test3') in friendService") {
                        expect(friend3?.name) == friendService.getFriend(by: "test3")?.name
                    }
                }
            }
            context("when inject singleton scope") {
                context("test case 1") {
                    var accountConfiguration: AccountConfiguration!
                    var networkManager: NetworkManager!
                    var sut: AccountService!
                    
                    beforeEach {
                        accountConfiguration = appContext.get(AccountConfiguration.self)
                        networkManager = appContext.get(NetworkManager.self)
                        
                        sut = appContext.get(AccountService.self)
                        
                        networkManager.request()
                        sut.networkManager.request()
                        accountConfiguration.accountService().networkManager.request()
                    }
                    it("requestCount of networkManager should equal to 3") {
                        expect(networkManager.requestCount) == 3
                    }
                }
                context("test case 2") {
                    var accountService: AccountService!
                    var friendService: FriendService!
                    var messageService: MessageService!
                    var testViewModel: TestViewModel!
                    var testView1: TestView1!
                    var testView2: TestView2!
                    
                    beforeEach {
                        accountService = appContext.get(AccountService.self)
                        friendService = appContext.get(FriendService.self)
                        messageService = appContext.get(MessageServiceImpl.self)
                        testViewModel = appContext.get(TestViewModel.self)
                        testView1 = TestView1()
                        testView2 = TestView2()
                        
                        accountService.logout()
                        friendService.accountService.logout()
                        messageService.accountService.logout()
                        testViewModel.accountService.logout()
                        testView1.viewModel.accountService.logout()
                        testView2.viewModel.accountService.logout()
                    }
                    it("logoutCount of accountService should equal to 6") {
                        expect(accountService.logoutCount) == 6
                    }
                }
                context("test case 3") {
                    var testService: TestService!
                    var libraryService: LibraryService!
                    
                    beforeEach {
                        testService = appContext.get(TestService.self)
                        libraryService = appContext.get(LibraryService.self)
                        
                        testService.test()
                        libraryService.testService.test()
                    }
                    it("testCount of testService should equal to 2") {
                        expect(testService.testCount) == 2
                    }
                }
                context("test case 4") {
                    var pointer1: Int = 0
                    var pointer2: Int = 0

                    beforeEach {
                        var object = appContext.get(HarryPotter.self)!
                        pointer1 = address(&object)
                        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
                        object = appContext.get(HarryPotter.self)!
                        pointer2 = address(&object)
                    }
                    it("pointer values of each other should equal") {
                        expect(pointer1) == pointer2
                    }
                }
            }
            context("when inject type of array") {
                var libraryService: LibraryService!
                var books: [Book] = []
                
                beforeEach {
                    libraryService = appContext.get(LibraryService.self)
                    books = appContext.get([Book].self)
                }
                it("books count of libraryService should equal to books count") {
                    expect(libraryService.books.count) == books.count
                }
            }
            context("when inject prototype scope") {
                var testViewModel: TestViewModel!
                var testView1: TestView1!
                
                beforeEach {
                    testViewModel = appContext.get(TestViewModel.self)
                    testView1 = TestView1()
                }
                context("when called test() method in viewModel of testView1") {
                    beforeEach {
                        testView1.viewModel.test()
                    }
                    it("testCount of testViewModel should equal to 0") {
                        expect(testViewModel.testCount) == 0
                    }
                    it("viewModel of testView's testCount should equal to 1") {
                        expect(testView1.viewModel.testCount) == 1
                    }
                }
                context("when called test() method in testViewModel") {
                    beforeEach {
                        testViewModel.test()
                    }
                    it("testCount of testViewModel should equal to 1") {
                        expect(testViewModel.testCount) == 1
                    }
                    it("viewModel of testView's testCount should equal to 0") {
                        expect(testView1.viewModel.testCount) == 0
                    }
                }
            }
            context("when inject mixed scope") {
                var friendService: FriendService!
                var messageService: MessageService!
                var testViewModel: TestViewModel!
                var testView1: TestView1!
                var testView3: TestView3!
                
                beforeEach {
                    friendService = appContext.get(FriendService.self)
                    messageService = appContext.get(MessageServiceImpl.self)
                    testViewModel = appContext.get(TestViewModel.self)
                    testView1 = TestView1()
                    testView3 = TestView3()
                    
                    friendService.listFriends()
                    messageService.friendService.listFriends()
                    testViewModel.friendService.listFriends()
                    testView1.viewModel.friendService.listFriends()
                    testView3.viewModel.friendService.listFriends()
                }
                it("requestCount of friendService should equal to 5") {
                    expect(friendService.requestCount) == 5
                }
            }
            context("when inject weak scope") {
                var weakPointer1: Int = 0
                var weakPointer2: Int = 0
                
                beforeEach {
                    weakPointer1 = unsafeBitCast(appContext.get(WeakViewModel.self)!, to: Int.self)
                    DispatchQueue.global(qos: .userInteractive).async {
                        weakPointer2 = unsafeBitCast(appContext.get(WeakViewModel.self)!, to: Int.self)
                    }
                }
                it("pointer values of each other should different") {
                    expect(weakPointer1).toEventuallyNot(equal(weakPointer2))
                }
                
                context("when store variable") {
                    var strongInstance1: WeakViewModel!
                    var strongInstance2: WeakViewModel!
                    
                    var strongPointer1: Int = 0
                    var strongPointer2: Int = 0
                    
                    beforeEach {
                        strongInstance1 = appContext.get(WeakViewModel.self)
                        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
                        strongInstance2 = appContext.get(WeakViewModel.self)
                        
                        strongPointer1 = unsafeBitCast(strongInstance1, to: Int.self)
                        strongPointer2 = unsafeBitCast(strongInstance2, to: Int.self)
                    }
                    it("pointer values of each other should equal") {
                        expect(strongPointer1) == strongPointer2
                    }
                }
            }
            context("when inject by Autowired") {
                describe("FriendService") {
                    var friendService: FriendServiceImpl!
                    
                    beforeEach {
                        friendService = appContext.get(FriendService.self) as? FriendServiceImpl
                    }
                    it("qualifier of friendService should be nil") {
                        expect(friendService.qualifier).to(beNil())
                    }
                    it("scope of friendService should equal to singleton") {
                        expect(friendService.scope) == .singleton
                    }
                }
                describe("NetworkManager") {
                    var networkManager: NetworkManagerImpl!
                    
                    beforeEach {
                        networkManager = appContext.get(NetworkManager.self) as? NetworkManagerImpl
                    }
                    it("qualifier of friendService should be nil") {
                        expect(networkManager.qualifier).to(beNil())
                    }
                    it("scope of friendService should equal to singleton") {
                        expect(networkManager.scope) == .singleton
                    }
                }
            }
            context("when inject by AutowiredFactory") {
                describe("FriendInfoViewModel") {
                    var sut: TestView3!
                    var friendInfoViewModel: FriendInfoViewModel!
                    
                    beforeEach {
                        sut = TestView3()
                        
                        friendInfoViewModel = sut.viewModel.generateInfo(by: "test1")
                    }
                    it("qualifier of friendInfoViewModel should be nil") {
                        expect(friendInfoViewModel.qualifier).to(beNil())
                    }
                    it("payload type of friendInfoViewModel should be FriendPayload") {
                        expect(String(describing: friendInfoViewModel.payloadType)) == String(describing: FriendPayload.self)
                    }
                }
            }
            context("when inject by LazyAutowired") {
                describe("TestService") {
                    var testService: TestService!
                    var testView3: TestView3!

                    beforeEach {
                        testService = appContext.get(TestService.self)
                        testView3 = TestView3()
                    }
                    it("dependency variable should be nil") {
                        expect(testService.friendService).to(beNil())
                        expect(testView3.test.accountService).to(beNil())
                    }
                    it("qualifier of testService should be nil") {
                        expect(testService.qualifier) == "qualifierTest"
                    }
                    it("scope of testService should be FriendPayload") {
                        expect(testService.scope) == .singleton
                    }

                    context("after running RunLoop once") {
                        beforeEach {
                            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
                        }
                        it("dependency variable should not be nil") {
                            expect(testService.friendService).notTo(beNil())
                        }
                    }
                }
                describe("LazyAutowiredQualifier") {
                    var lazyAutowiredQualifier: LazyAutowiredQualifier!

                    beforeEach {
                        lazyAutowiredQualifier = appContext.get(LazyAutowiredQualifier.self)
                    }
                    it("dependency variable should be nil") {
                        expect(lazyAutowiredQualifier.testService).to(beNil())
                    }

                    context("after running RunLoop once") {
                        beforeEach {
                            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
                        }
                        it("dependency variable should not be nil") {
                            expect(lazyAutowiredQualifier.testService).notTo(beNil())
                        }
                    }
                }
            }
            context("when inject by LazyAutowiredFactory") {
                var factoryTest: FactoryTest!
                
                beforeEach {
                    factoryTest = appContext.get(
                        FactoryTest.self,
                        qualifier: "",
                        payload: TestPayload(with: (test1: false, test2: [1, 2, 3, 4, 5]))
                    )
                }
                it("qualifier of factoryTest should be nil") {
                    expect(factoryTest.qualifier).to(beNil())
                }
                it("payload type of factoryTest should be FriendPayload") {
                    expect(String(describing: factoryTest.payloadType)) == String(describing: TestPayload.self)
                }
            }
            describe("multi-container test") {
                var accountService: AccountService!
                var books: [Book] = []
                
                beforeEach {
                    accountService = appContext.get(AccountService.self, qualifier: "facebook")!
                    books = appContext.get([Book].self, resolveRole: .default)
                }
                it("accountService should be normal instance") {
                    expect(accountService.logout()) == true
                    expect(accountService.logoutCount) == 1
                    expect(books.count) == 3
                }
                
                context("when load other ModuleFactory") {
                    let testModule: ModuleFactory = {
                        let module = ModuleFactory()
                        module.register(
                            AccountService.self,
                            resolver: {
                                let networkManager = appContext.get(NetworkManager.self)!
                                let libraryService = appContext.get(LibraryService.self)!
                                return MockAccountService(networkManager, libraryService)
                            },
                            qualifier: "facebook",
                            scope: .singleton
                        )
                        module.register(
                            MockBook.self,
                            resolver: {
                                return MockBook()
                            },
                            qualifier: "Test",
                            scope: .singleton
                        ).link(Book.self)
                        
                        return module
                    }()
                    
                    beforeEach {
                        appContext.load(testModule, priority: .high)
                        
                        accountService = appContext.get(AccountService.self, qualifier: "facebook")!
                        books = appContext.get([Book].self, resolveRole: .default)
                    }
                    it("accountService should be mock instance") {
                        expect(accountService.logout()) == false
                        expect(accountService.logoutCount) == 0
                        expect(books.count) == 1
                    }
                    
                    context("when unload other MoudleFactory") {
                        beforeEach {
                            appContext.unload(testModule)
                            
                            accountService = appContext.get(AccountService.self, qualifier: "facebook")!
                            books = appContext.get([Book].self, qualifier: "Novel")
                        }
                        it("accountService should be normal instance") {
                            expect(accountService.logout()) == true
                            expect(accountService.logoutCount) == 1
                            expect(books.count) == 2
                        }
                    }
                }
            }
            describe("Inject protocol test") {
                context("Inject(T)") {
                    var accountService: AccountService!
                    
                    beforeEach {
                        accountService = self.Inject(AccountService.self)
                    }
                    it("accountService should be not nil") {
                        expect(accountService).notTo(beNil())
                    }
                }
                context("Inject([T])") {
                    var books: [Book] = []
                    
                    beforeEach {
                        books = self.Inject([Book].self)
                    }
                    it("books count should equal to 3") {
                        expect(books.count) == 3
                    }
                }
                context("Inject(Factory)") {
                    var friendInfoViewModel: FriendInfoViewModel!
                    
                    beforeEach {
                        friendInfoViewModel = self.Inject(
                            FriendInfoViewModel.self,
                            with: (
                                userID: "test1",
                                cachedName: "test man"
                            )
                        )
                    }
                    it("friendInfoViewModel should be not nil") {
                        expect(friendInfoViewModel).notTo(beNil())
                    }
                }
                context("Inject([Factory])") {
                    var viewModels: [FriendInfoViewModel] = []
                    
                    beforeEach {
                        viewModels = self.Inject(
                            [FriendInfoViewModel].self,
                            with: (
                                userID: "test1",
                                cachedName: "test man"
                            )
                        )
                    }
                    it("viewModels should equal to 1") {
                        expect(viewModels.count) == 1
                    }
                }
            }
            context("when not load example factory") {
                it("all instance should be nil") {
                    expect(appContext.get(withoutResolve: AccountService.self, qualifier: "")).to(beNil())
                    expect(appContext.get(withoutResolve: [Book].self, qualifier: "").count) == 0
                    expect(appContext.get(AccountService.self)).notTo(beNil())
                    expect(appContext.get([Book].self).count) == 3
                }
            }
            context("when multi-thread environment") {
                var list1: [AnyObject?] = []
                var list2: [AnyObject?] = []
                var list3: [AnyObject?] = []
                var operationQueue: OperationQueue!

                beforeEach {
                    list1 = (0..<20).map { _ in nil }
                    list2 = (0..<20).map { _ in nil }
                    list3 = (0..<20).map { _ in nil }

                    operationQueue = OperationQueue()
                    operationQueue.maxConcurrentOperationCount = 100

                    for i in 0..<20 {
                        operationQueue.addOperation {
                            list1[i] = appContext.get(NetworkManager.self) as AnyObject
                        }
                        operationQueue.addOperation {
                            list2[i] = appContext.get(AccountService.self, qualifier: "facebook") as AnyObject
                        }
                        operationQueue.addOperation {
                            list3[i] = appContext.get(LibraryService.self) as AnyObject
                        }
                    }
                    operationQueue.waitUntilAllOperationsAreFinished()
                }
                it("same objects must have the same pointer") {
                    expect(list1.filter { $0 == nil }.count) == 0
                    expect(list2.filter { $0 == nil }.count) == 0
                    expect(list3.filter { $0 == nil }.count) == 0
                    expect {
                        let pointerList: [Int] = list1.compactMap { $0 }.map { unsafeBitCast($0!, to: Int.self) }
                        return !pointerList.contains(where: { pointerList[0] != $0 })
                    } == true
                    expect {
                        let pointerList: [Int] = list2.compactMap { $0 }.map { unsafeBitCast($0!, to: Int.self) }
                        return !pointerList.contains(where: { pointerList[0] != $0 })
                    } == true

                    expect {
                        let pointerList: [Int] = list3.compactMap { $0 }.map { unsafeBitCast($0!, to: Int.self) }
                        return !pointerList.contains(where: { pointerList[0] != $0 })
                    } == true
                }
            }
            describe("struct test") {
                context("when inject that inherit Component") {
                    var sut: StructWithComponent!

                    beforeEach {
                        sut = appContext.get(StructWithComponent.self)
                    }
                    it("sut should be not nil") {
                        expect(sut).notTo(beNil())
                    }
                }
                context("when inject that inherit Autowired") {
                    var sut: StructWithAutowired!

                    beforeEach {
                        sut = appContext.get(StructWithAutowired.self)
                    }
                    it("sut should be not nil") {
                        expect(sut).notTo(beNil())
                    }
                }
                context("when inject that inherit AutowiredFactory") {
                    var sut: StructWithAutowiredFactory!

                    beforeEach {
                        sut = self.Inject(StructWithAutowiredFactory.self, with: (a: 1, b: false, c: 0.2))
                    }
                    it("sut's friendService should be not nil") {
                        expect(sut).notTo(beNil())
                    }
                }
            }
            describe("property test") {
                describe("by Autowired") {
                    var sut: PropertyAutowired!

                    beforeEach {
                        sut = appContext.get(PropertyAutowired.self)
                    }
                    it("sut's qualifier of network should be 'dev'") {
                        expect(sut.network.qualifier) == "dev"
                    }
                }
                describe("by Inject") {
                    var sut: PropertyInject!

                    beforeEach {
                        sut = appContext.get(PropertyInject.self)
                    }
                    it("sut's qualifier of method should be 'get'") {
                        expect(sut.method.qualifier) == "get"
                    }
                }
                describe("by single value") {
                    var sut: String?

                    beforeEach {
                        sut = appContext.getProperty("server.url") as? String
                    }
                    it("sut should be 'http://dev.test.com'") {
                        expect(sut) == "http://dev.test.com"
                    }
                }
                describe("by ServerConfig") {
                    var sut: ServerConfig?

                    beforeEach {
                        sut = appContext.get(ServerConfig.self)
                    }
                    it("sut's method should be 'get'") {
                        expect(sut?.method) == "get"
                    }
                    it("sut's url should be 'http://dev.test.com'") {
                        expect(sut?.url) == "http://dev.test.com"
                    }
                }
                describe("by InjectProperty") {
                    var sut: InjectPropertyTest!

                    beforeEach {
                        sut = appContext.get(InjectPropertyTest.self)
                    }
                    it("sut's url should be 'http://dev.test.com'") {
                        expect(sut.url) == "http://dev.test.com"
                    }
                    it("sut's method should be 'get'") {
                        expect(sut.method) == "get"
                    }
                    it("sut's test should be nil") {
                        expect(sut.test).to(beNil())
                    }
                }
            }
        }
    }
}
