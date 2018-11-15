import Deli

struct TroisiemeHumanite: Novel, Component {
    var qualifier: String? { return nil }
    var scope: Scope { return .singleton }
}
