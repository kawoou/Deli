import Deli

class FactoryTest: LazyAutowiredFactory {
    var accountService: AccountService!
    
    let test1: Bool
    let test2: [Int]
    
    func inject(facebook accountService: AccountService) {
        self.accountService = accountService
    }
    
    required init(payload: TestPayload) {
        self.test1 = payload.test1
        self.test2 = payload.test2
    }
}
