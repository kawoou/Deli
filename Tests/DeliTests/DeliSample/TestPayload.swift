import Deli

class TestPayload: Paload {
    let test1: Bool
    let test2: [Int]
    
    required init(with argument: (test1: Bool, test2: [Int])) {
        self.test1 = argument.test1
        self.test2 = argument.test2
    }
}
