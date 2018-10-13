import Deli

protocol RobotHead {}

class HappyRobotHead: RobotHead, Component {
    var qualifier: String? = "happy"
}
class AngryRobotHead: RobotHead, Component {
    var qualifier: String? = "angry"
}
