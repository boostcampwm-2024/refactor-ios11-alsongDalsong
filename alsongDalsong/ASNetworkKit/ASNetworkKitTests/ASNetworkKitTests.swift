@testable import ASNetworkKit
import Foundation
import Testing

struct ASNetworkKitTests {
    var networkManager = ASNetworkManager(urlSession: MockURLSession(), cacheManager: MockCacheManager())
    let endpoint: MockEndpoint
    let testData = "hello, world!".data(using: .utf8)!
    let testResponse = HTTPURLResponse(url: URL(string: "https://www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

    init() {
        endpoint = MockEndpoint(path: .mock, method: .get)
    }

    @Test("Endpoint 업데이트") func updateEndpoint() async throws {
        let updatedEndpoint = endpoint.update(\.method, with: .patch)
        #expect(updatedEndpoint == MockEndpoint(path: .mock, method: .patch))

        let twiceUpdatedEndpoint = endpoint
            .update(\.headers, with: ["hello": "world"])
            .update(\.body, with: testData)
        #expect(twiceUpdatedEndpoint.headers == ["hello": "world"])
        #expect(twiceUpdatedEndpoint.body == testData)
    }

    @Test("올바른 응답") func response() async throws {
        let mockURLSession = MockURLSession()
        mockURLSession.testData = testData
        mockURLSession.testResponse = testResponse
        let networkManager = ASNetworkManager(urlSession: mockURLSession, cacheManager: MockCacheManager())

        let response = try await networkManager.sendRequest(to: endpoint, type: .json)
        #expect(response == testData)
    }
}
