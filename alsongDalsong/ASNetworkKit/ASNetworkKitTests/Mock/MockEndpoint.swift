import ASNetworkKit
import Foundation

struct MockEndpoint: Endpoint, Equatable {
    var scheme: String = "https"
    var host: String = "host"
    var path: Path
    var method: HTTPMethod
    var headers: [String : String] = [:]
    var body: Data?
    var queryItems: [URLQueryItem]?
    
    enum Path: CustomStringConvertible {
        case mock
        
        var description: String { "/mock" }
    }
}
