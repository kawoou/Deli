import Deli

class AccountConfiguration: Configuration {

    let accountService = Config(AccountService.self, NetworkManager.self, LibraryService.self) { (networkManager, libraryService) in
        return AccountServiceImpl(networkManager, libraryService)
    }

}
