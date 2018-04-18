import Deli

class TestViewModel: Autowired {
    var scope: Scope {
        return .prototype
    }
    
    var testCount: Int = 0

    let accountService: AccountService
    let friendService: FriendService
    
    func test() {
        testCount += 1
    }

    required init(_ accountService: AccountService, _ friendService: FriendService) {
        self.accountService = accountService
        self.friendService = friendService
    }
}
