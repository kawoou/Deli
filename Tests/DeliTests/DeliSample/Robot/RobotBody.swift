import Deli

protocol RobotBody {}

class BlueRobotBody: RobotBody, Component {
    var qualifier: String? = "blue"
}
class RedRobotBody: RobotBody, Component {
    var qualifier: String? = "red"
}
