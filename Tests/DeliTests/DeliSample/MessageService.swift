import Deli

protocol MessageService {
    var friendService: FriendService! { get }
    var accountService: AccountService! { get }
    
    func listMessage() -> [String]
}
class MessageServiceImpl: MessageService, Autowired {
    typealias Dep1 = FriendService
    typealias Dep2 = AccountService
    
    let friendService: FriendService!
    let accountService: AccountService!
    
    func listMessage() -> [String] {
        return []
    }
    
    required init(_ dep1: MessageServiceImpl.Dep1, facebook dep2: Dep2) {
        friendService = dep1
        accountService = dep2
    }
}
