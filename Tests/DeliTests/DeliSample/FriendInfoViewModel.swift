import Deli

class FriendInfoViewModel: AutowiredFactory {
    let accountService: AccountService
    
    let userID: String
    var name: String
    
    required init(_ accountService: AccountService, payload: FriendPayload) {
        self.accountService = accountService
        self.userID = payload.userID
        self.name = payload.cachedName
    }
}
