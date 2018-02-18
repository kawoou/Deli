import Delis

protocol AccountService {
    func login(account: String, password: String) -> Bool
    func logout() -> Bool
}
class AccountServiceImpl: AccountService, Autowired {
    let networkManager: NetworkManager
    let libraryService: LibraryService

    func login(account: String, password: String) -> Bool {
        return true
    }
    func logout() -> Bool {
        return true
    }

    required init(_ networkManager: NetworkManager, _ libraryService: LibraryService) {
        self.networkManager = networkManager
        self.libraryService = libraryService
    }
}
