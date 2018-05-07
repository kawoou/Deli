import Deli

class FriendPayload: Payload {
    let userID: String
    let cachedName: String
    
    required init(with argument: (userID: String, cachedName: String)) {
        userID = argument.userID
        cachedName = argument.cachedName
    }
}
