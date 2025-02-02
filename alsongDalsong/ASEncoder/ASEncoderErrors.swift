import Foundation

struct ASEncoderErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    enum ErrorType {
        case encode
    }

    var errorDescription: String? {
        return "[\(file):\(line)] \(type) 에러: \n\(reason)"
    }
}
