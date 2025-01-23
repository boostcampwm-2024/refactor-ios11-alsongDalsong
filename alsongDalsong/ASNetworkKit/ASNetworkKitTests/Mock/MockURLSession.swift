import ASNetworkKit
import Foundation

final class MockURLSession: URLSessionProtocol {
    public var testData: Data?
    public var testResponse: HTTPURLResponse?

    public func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        let data = testData ?? Data()
        let response = testResponse ?? URLResponse()
        return (data, response)
    }
}
