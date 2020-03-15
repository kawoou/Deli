import Deli

class FriendInfoViewModel: AutowiredFactory {
    typealias _Payload = FriendPayload
    
    let accountService: AccountService
    
    let userID: String
    var name: String
    
    required init(facebook accountService: AccountService, payload: FriendPayload) {
        self.accountService = accountService
        self.userID = payload.userID
        self.name = payload.cachedName
    }
}
