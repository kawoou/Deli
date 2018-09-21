import Deli

protocol AccountService {
    var networkManager: NetworkManager { get }
    var libraryService: LibraryService { get }
    
    var logoutCount: Int { get }
    
    func login(account: String, password: String) -> Bool
    
    @discardableResult
    func logout() -> Bool
}
class AccountServiceImpl: AccountService {
    
    let networkManager: NetworkManager
    let libraryService: LibraryService
    
    var logoutCount: Int = 0

    func login(account: String, password: String) -> Bool {
        return true
    }
    
    @discardableResult
    func logout() -> Bool {
        logoutCount += 1
        return true
    }

    init(_ networkManager: NetworkManager, _ libraryService: LibraryService) {
        self.networkManager = networkManager
        self.libraryService = libraryService
    }
}
