//
//  DeliTests.swift
//  DeliTests
//

import Foundation
import XCTest
@testable import Deli

class DeliTests: XCTestCase, Inject {
    var factory: DeliFactory!
    
    override func setUp() {
        super.setUp()
    }
    
    func testAutowired() {
        factory = DeliFactory()
        
        let friendService = Inject(FriendService.self) as! FriendServiceImpl
        XCTAssertEqual(friendService.qualifier, nil)
        XCTAssertEqual(friendService.scope, .singleton)
        
        let networkManager = Inject(NetworkManager.self) as! NetworkManagerImpl
        XCTAssertEqual(networkManager.qualifier, nil)
        XCTAssertEqual(networkManager.scope, .singleton)
        
        AppContext.shared.reset()
    }
    
    func testEmpty() {
        XCTAssertNil(AppContext.shared.get(withoutResolve: AccountService.self, qualifier: ""))
        XCTAssertEqual(AppContext.shared.get(withoutResolve: [Book].self, qualifier: "").count, 0)
        XCTAssertNil(AppContext.shared.get(AccountService.self, qualifier: ""))
        XCTAssertEqual(AppContext.shared.get([Book].self, qualifier: "").count, 0)
    }
    func testFactory() {
        factory = DeliFactory()
        
        let accountConfiguration = Inject(AccountConfiguration.self)
        let accountService1 = Inject(AccountService.self)
        let accountService2 = accountConfiguration.accountService()
        let friendService = Inject(FriendService.self)
        let libraryService = Inject(LibraryService.self)
        let messageService = Inject(MessageServiceImpl.self)
        let networkManager = Inject(NetworkManager.self)
        let testService = Inject(TestService.self)
        let testViewModel = Inject(TestViewModel.self)
        let books = Inject([Book].self)
        let testView1 = TestView1()
        let testView2 = TestView2()
        
        _ = networkManager.request()
        XCTAssertEqual(networkManager.requestCount, 1)
        _ = accountService1.networkManager.request()
        XCTAssertEqual(networkManager.requestCount, 2)
        _ = accountService2.networkManager.request()
        XCTAssertEqual(networkManager.requestCount, 3)
        
        XCTAssertEqual(libraryService.books.count, books.count)
        
        _ = accountService1.logout()
        XCTAssertEqual(accountService1.logoutCount, 1)
        _ = accountService2.logout()
        XCTAssertEqual(accountService1.logoutCount, 2)
        _ = friendService.accountService.logout()
        XCTAssertEqual(accountService1.logoutCount, 3)
        _ = messageService.accountService.logout()
        XCTAssertEqual(accountService1.logoutCount, 4)
        _ = testViewModel.accountService.logout()
        XCTAssertEqual(accountService1.logoutCount, 5)
        _ = testView1.viewModel.accountService.logout()
        XCTAssertEqual(accountService1.logoutCount, 6)
        _ = testView2.viewModel.accountService.logout()
        XCTAssertEqual(accountService1.logoutCount, 7)
        
        libraryService.testService.test()
        XCTAssertEqual(testService.testCount, 1)
        testService.test()
        XCTAssertEqual(testService.testCount, 2)
        
        testView1.viewModel.test()
        XCTAssertEqual(testViewModel.testCount, 0)
        XCTAssertEqual(testView1.viewModel.testCount, 1)
        XCTAssertEqual(testView2.viewModel.testCount, 0)
        testView2.viewModel.test()
        XCTAssertEqual(testViewModel.testCount, 0)
        XCTAssertEqual(testView1.viewModel.testCount, 1)
        XCTAssertEqual(testView2.viewModel.testCount, 1)
        testViewModel.test()
        XCTAssertEqual(testViewModel.testCount, 1)
        XCTAssertEqual(testView1.viewModel.testCount, 1)
        XCTAssertEqual(testView2.viewModel.testCount, 1)
        
        _ = friendService.listFriends()
        XCTAssertEqual(friendService.requestCount, 1)
        _ = messageService.friendService.listFriends()
        XCTAssertEqual(friendService.requestCount, 2)
        _ = testViewModel.friendService.listFriends()
        XCTAssertEqual(friendService.requestCount, 3)
        _ = testView1.viewModel.friendService.listFriends()
        XCTAssertEqual(friendService.requestCount, 4)
        _ = testView2.viewModel.friendService.listFriends()
        XCTAssertEqual(friendService.requestCount, 5)
        
        XCTAssertNil(testService.friendService)
        
        AppContext.shared.reset()
    }
    func testWithResolve() {
        factory = DeliFactory()
        
        AppContext.shared.setTestMode(false, qualifierPrefix: "")
        XCTAssertNil(AppContext.shared.get(withoutResolve: FriendService.self, qualifier: ""))
        XCTAssertEqual(AppContext.shared.get(withoutResolve: [Book].self, qualifier: "").count, 0)
        
        AppContext.shared.setTestMode(true, qualifierPrefix: "test")
        XCTAssertNil(AppContext.shared.get(withoutResolve: FriendService.self, qualifier: ""))
        XCTAssertEqual(AppContext.shared.get(withoutResolve: [Book].self, qualifier: "").count, 0)
        
        AppContext.shared.setTestMode(false, qualifierPrefix: "")
        XCTAssertEqual(AppContext.shared.get(withoutResolve: [Book].self, qualifier: "Novel").count, 0)
        
        XCTAssertNotNil(AppContext.shared.get(withoutResolve: TestViewModel.self, qualifier: ""))
        
        AppContext.shared.reset()
    }
    func testTestMode() {
        AppContext.shared.register(
            AccountService.self,
            resolver: {
                let networkManager = AppContext.shared.get(NetworkManager.self, qualifier: "")!
                let libraryService = AppContext.shared.get(LibraryService.self, qualifier: "")!
                return MockAccountService(networkManager, libraryService)
            },
            qualifier: "test",
            scope: .singleton
        )
        AppContext.shared.register(
            MockBook.self,
            resolver: {
                return MockBook()
            },
            qualifier: "testTest",
            scope: .singleton
        ).link(Book.self)
        
        factory = DeliFactory()
        
        /// Test Mode: OFF
        XCTAssertEqual(AppContext.shared.isTestMode, false)
        
        let accountService = AppContext.shared.get(AccountService.self, qualifier: "")!
        XCTAssertEqual(accountService.logout(), true)
        XCTAssertEqual(accountService.logoutCount, 1)
        let books = Inject([Book].self)
        XCTAssertEqual(books.count, 4)

        /// Test Mode: ON
        AppContext.shared.setTestMode(true, qualifierPrefix: "test")
        XCTAssertEqual(AppContext.shared.isTestMode, true)
        
        let mockAccountService = AppContext.shared.get(AccountService.self, qualifier: "")!
        XCTAssertEqual(mockAccountService.logout(), false)
        XCTAssertEqual(mockAccountService.logoutCount, 0)
        let mockBooks = Inject([Book].self, qualifier: "")
        XCTAssertEqual(mockBooks.count, 1)
        
        /// Test Mode: OFF
        AppContext.shared.setTestMode(false, qualifierPrefix: "")
        XCTAssertEqual(AppContext.shared.isTestMode, false)
        
        let oldAccountService = AppContext.shared.get(AccountService.self, qualifier: "")!
        XCTAssertEqual(oldAccountService.logout(), true)
        XCTAssertEqual(oldAccountService.logoutCount, 2)
        let novelBooks = Inject([Book].self, qualifier: "Novel")
        XCTAssertEqual(novelBooks.count, 2)

        AppContext.shared.reset()
    }
}
