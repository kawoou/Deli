import Deli

class AccountConfiguration: Configuration {

    let facebookAccountService = Config(AccountService.self, NetworkManager.self, LibraryService.self, qualifier: "facebook") { (networkManager, libraryService) in
        return AccountServiceImpl(networkManager, libraryService)
    }

    let googleAccountService = Config(AccountService.self, NetworkManager.self, LibraryService.self, qualifier: "google") { (networkManager, libraryService) in
        return AccountServiceImpl(networkManager, libraryService)
    }

}
