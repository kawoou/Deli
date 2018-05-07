import Deli

class UserPayload: Payload {
    let userID: String
    
    required init(with argument: (String)) {
        self.userID = argument
    }
}
