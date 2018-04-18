import Deli

protocol NetworkManager {
    var requestCount: Int { get }
    
    func request() -> String
}
class NetworkManagerImpl: NetworkManager, Component {
    var requestCount: Int = 0
    
    func request() -> String {
        requestCount += 1
        return ""
    }
}
