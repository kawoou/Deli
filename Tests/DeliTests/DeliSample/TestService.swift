import Deli

class TestService: LazyAutowired {
    var qualifier: String? = "qualifierTest"

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
