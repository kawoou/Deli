import Deli

protocol NetworkManager {
    var requestCount: Int { get }
    
    @discardableResult
    func request() -> String
}
class NetworkManagerImpl: NetworkManager, Component {
    var requestCount: Int = 0
    
    @discardableResult
    func request() -> String {
        requestCount += 1
        return ""
    }
}
