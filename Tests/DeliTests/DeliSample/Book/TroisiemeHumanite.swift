import Deli

struct TroisiemeHumanite: Novel, Component {
    var qualifier: String? { return "Novel" }
    var scope: Scope { return .singleton }
}
