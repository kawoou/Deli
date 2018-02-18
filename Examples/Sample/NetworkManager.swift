import Delis

protocol NetworkManager {
    func request() -> String
}
class NetworkManagerImpl: NetworkManager, Component {
    func request() -> String {
        return ""
    }
}
