@testable import ASDecoder
import Foundation
import Testing

struct ASDecoderTests {
    struct SampleData: Decodable, Equatable {
        let id: Int
        let name: String
    }

    @Test("디코딩 성공") func decode() async throws {
        let jsonString = """
                {
                    "id": 1,
                    "name": "아이유"
                }
            """
        let jsonData = try #require(jsonString.data(using: .utf8))
        let result: Result<Data, Error> = .success(jsonData)

        let decodedData: SampleData = try await ASDecoder.handleResponse(result: result)
        #expect(decodedData == SampleData(id: 1, name: "아이유"))
    }
}
