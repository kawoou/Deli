import Deli

class TestPayload: Payload {
    let test1: Bool
    let test2: [Int]
    
    required init(with argument: (Bool, [Int])) {
        self.test1 = argument.0
        self.test2 = argument.1
    }
}
