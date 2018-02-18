import Delis

protocol MessageService {
    func listMessage() -> [String]
}
class MessageServiceImpl: MessageService, Autowired {
    typealias Dep1 = FriendService
    typealias Dep2 = AccountService
    
    func listMessage() -> [String] {
        return []
    }
    
    required init(_ dep1: MessageServiceImpl.Dep1, _ dep2: Dep2) {
        
    }
}
