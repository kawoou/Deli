import Deli

protocol FriendService {
    var requestCount: Int { get }
    var accountService: AccountService { get }
    
    func listFriends() -> [Friend]
    func isExistFriend(by id: String) -> Bool
    func getFriend(by id: String) -> Friend?
}
class FriendServiceImpl: FriendService, Autowired {
    let accountService: AccountService
    
    var requestCount: Int = 0
    
    let friendList: [String: Friend] = [
        "test1": Friend(id: "test1", name: "Tester 1", age: 10),
        "test2": Friend(id: "test2", name: "Tester 2", age: 20),
        "test3": Friend(id: "test3", name: "Tester 3", age: 30)
    ]

    func listFriends() -> [Friend] {
        requestCount += 1
        
        return Array(friendList.values)
    }
    func isExistFriend(by id: String) -> Bool {
        return friendList[id] != nil
    }
    func getFriend(by id: String) -> Friend? {
        return friendList[id]
    }

    required init(_ accountService: AccountService) {
        self.accountService = accountService
    }
}
