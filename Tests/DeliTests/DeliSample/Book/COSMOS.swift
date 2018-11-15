import Deli

struct COSMOS: Science, Component {
    var qualifier: String? { return nil }
    var scope: Scope { return .singleton }
}
