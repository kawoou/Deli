import Deli

class RobotPayload: Payload {
    let head: RobotHead
    let body: RobotBody

    required init(with argument: (head: RobotHead, body: RobotBody)) {
        self.head = argument.head
        self.body = argument.body
    }
}

class Robot: AutowiredFactory {
    let head: RobotHead
    let body: RobotBody

    required init(payload: RobotPayload) {
        head = payload.head
        body = payload.body
    }
}
