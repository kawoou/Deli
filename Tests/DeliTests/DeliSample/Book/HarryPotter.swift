import Deli

struct HarryPotter: Novel, Component {
    var qualifier: String? { return nil }
    var scope: Scope { return .singleton }
}
