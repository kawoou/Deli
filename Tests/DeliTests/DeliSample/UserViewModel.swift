import Deli

class UserViewModel: AutowiredFactory {
    let accountService: AccountService
    let userID: String
    
    required init(_ accountService: AccountService, payload: UserPayload) {
        self.accountService = accountService
        self.userID = payload.userID
    }
}
