import Foundation

public enum ASDecoder {
    public static func decode<T: Decodable>(_: T.Type, from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode(T.self, from: data)
        } catch {
            throw ASDecoderErrors(type: .decode, reason: error.localizedDescription, file: #file, line: #line)
        }
    }

    public static func handleResponse<T: Decodable>(result: Result<Data, Error>) async throws -> T {
        switch result {
            case let .success(data):
                do {
                    let decodedData = try decode(T.self, from: data)
                    return decodedData
                } catch {
                    throw error
                }
            case let .failure(error):
                throw error
        }
    }
}
