import Deli

class FactoryTest: LazyAutowiredFactory {
    var accountService: AccountService!
    var test1: Bool!
    var test2: [Int]!
    
    func inject(facebook accountService: AccountService) {
        self.accountService = accountService
    }
    
    required init(payload: TestPayload) {
        self.test1 = payload.test1
        self.test2 = payload.test2
    }
}
