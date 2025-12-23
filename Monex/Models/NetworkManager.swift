import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = true
    var connectionDescription: String {
        if isConnected {
            return "Connected"
        } else {
            return "Not connected"
        }
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkConnection(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            completion(self.isConnected)
        }
    }
} 