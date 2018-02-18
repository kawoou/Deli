import Delis

protocol FriendService {
    func listFriends() -> [String]
}
class FriendServiceImpl: FriendService, Autowired {
    let accountService: AccountService

    func listFriends() -> [String] {
        return [
            "test1",
            "test2",
            "test3"
        ]
    }

    required init(_ accountService: AccountService) {
        self.accountService = accountService
    }
}
