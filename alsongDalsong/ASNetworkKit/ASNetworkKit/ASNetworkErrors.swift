import Foundation

public struct ASNetworkErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    public init(type: ErrorType, reason: String, file: String, line: Int) {
        self.type = type
        self.reason = reason
        self.file = file
        self.line = line
    }

    public enum ErrorType {
        case serverError
        case urlError
        case getAvatarUrls
        case firebaseSignIn, firebaseSignOut
        case firebaseListener
        case responseError
    }

    public var errorDescription: String? {
        return "[\(file):\(line)] \(type) 에러: \(reason)"
    }
}

