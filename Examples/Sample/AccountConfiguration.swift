import Delis

class AccountConfiguration: Configuration {

    let accountService: AccountService = Config(AccountService.self, NetworkManager.self, LibraryService.self) { (networkManager, libraryService) in
        return AccountServiceImpl(networkManager, libraryService)
    }

}
