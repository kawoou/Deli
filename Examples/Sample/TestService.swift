import Delis

class TestService: LazyAutowired {
    let friendService: FriendService!

    func inject(_ friendService: FriendServiceImpl) {
        self.friendService = friendService
    }

    init() {
        
    }
}
