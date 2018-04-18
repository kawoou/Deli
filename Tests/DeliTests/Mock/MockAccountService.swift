//
//  MockAccountService.swift
//  DeliTests
//

import Deli

class MockAccountService: AccountService, Autowired {
    var logoutCount: Int = 0
    
    let networkManager: NetworkManager
    let libraryService: LibraryService
    
    func login(account: String, password: String) -> Bool {
        return false
    }
    func logout() -> Bool {
        return false
    }
    
    required init(_ networkManager: NetworkManager, _ libraryService: LibraryService) {
        self.networkManager = networkManager
        self.libraryService = libraryService
    }
}
