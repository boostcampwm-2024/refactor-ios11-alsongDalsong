import Foundation

enum ASEncoderErrors: Error, LocalizedError {
    case encodeError(reason: String)

    var errorDescription: String? {
        switch self {
            case .encodeError(let reason):
                return "ASEncoder.swift encode() 에러: 데이터 인코딩 중 오류가 발생했습니다.\n\(reason)"
        }
    }
}
