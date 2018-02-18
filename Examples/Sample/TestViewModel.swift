import Delis

class TestViewModel: Autowired {
    static var scope: Scope {
        return .prototype
    }

    let accountService: AccountService
    let friendService: FriendService

    required init(_ accountService: AccountService, _ friendService: FriendService) {
        self.accountService = accountService
        self.friendService = friendService
    }
}
