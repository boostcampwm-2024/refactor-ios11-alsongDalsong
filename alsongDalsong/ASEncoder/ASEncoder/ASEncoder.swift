import Foundation

public enum ASEncoder {
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .useDefaultKeys
            encoder.outputFormatting = [.prettyPrinted]

            return try encoder.encode(value)
        } catch {
            throw ASEncoderErrors.encodeError(reason: error.localizedDescription)
        }
    }
}
