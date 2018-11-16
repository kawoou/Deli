import Deli

struct COSMOS: Science, Component {
    var qualifier: String? { return "Science" }
    var scope: Scope { return .singleton }
}
