import Deli

class FriendListViewModel: Autowired {
    let friendService: FriendService
    
    func generateInfo(by id: String) -> FriendInfoViewModel? {
        guard let friend = friendService.getFriend(by: id) else { return nil }
        
        return Inject(
            FriendInfoViewModel.self,
            with: (
                userID: friend.id,
                cachedName: friend.name
            )
        )
    }
    
    required init(_ friendService: FriendService) {
        self.friendService = friendService
    }
}
