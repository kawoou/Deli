import Deli

struct HarryPotter: Novel, Component {
    var qualifier: String? { return "Novel" }
    var scope: Scope { return .singleton }
}
