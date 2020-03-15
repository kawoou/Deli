import Deli

class UserViewModel: AutowiredFactory {
    typealias _Payload = UserPayload
    
    let accountService: AccountService
    let userID: String
    
    required init(facebook accountService: AccountService, payload: UserPayload) {
        self.accountService = accountService
        self.userID = payload.userID
    }
}
