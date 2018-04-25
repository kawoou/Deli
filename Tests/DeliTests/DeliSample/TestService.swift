import Deli

class TestService: LazyAutowired {
    var qualifier = "qualifierTest"

    var friendService: FriendService!
    
    var testCount: Int = 0
    
    func test() {
        testCount += 1
    }

    func inject(_ friendService: FriendServiceImpl) {
        self.friendService = friendService
    }

    required init() {
        
    }
}
