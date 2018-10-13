import Deli

class RobotFactory: Component {

    func makeRobot() -> Robot {
        return Inject(
            Robot.self,
            with: (
                head: Inject(RobotHead.self, qualifier: "happy"),
                body: Inject(RobotBody.self, qualifier: "red")
            )
        )
    }
}
