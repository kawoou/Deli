import Deli

protocol FriendService {
    var requestCount: Int { get }
    var accountService: AccountService { get }
    
    func listFriends() -> [String]
}
class FriendServiceImpl: FriendService, Autowired {
    let accountService: AccountService
    
    var requestCount: Int = 0

    func listFriends() -> [String] {
        requestCount += 1
        
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
