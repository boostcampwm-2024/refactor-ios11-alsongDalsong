import Foundation

enum ASDecoderErrors: Error, LocalizedError {
    case decodeError(reason: String)

    var errorDescription: String? {
        switch self {
            case .decodeError(let reason):
                return "ASDecoder.swift decode() 에러: 데이터 디코딩 중 오류가 발생했습니다.\n\(reason)"
        }
    }
}
