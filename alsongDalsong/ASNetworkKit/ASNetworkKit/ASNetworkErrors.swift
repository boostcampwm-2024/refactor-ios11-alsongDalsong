import Foundation

public enum ASNetworkErrors: Error, LocalizedError {
    case serverError(message: String)
    case urlError
    case getAvatarUrlsError(reason: String)
    case FirebaseSignInError(reason: String)
    case FirebaseSignOutError(reason: String)
    case FirebaseListenerError(reason: String?)
    case responseError

    public var errorDescription: String? {
        switch self {
            case let .serverError(message: message):
                return message
            case .urlError:
                return "ASNetworkManager.swift URL 에러: URL이 제대로 입력되지 않았습니다."
            case .getAvatarUrlsError(let reason):
                return "ASFirebaseStorage.swift getAvatarUrls() 에러: 서버에서 응답이 없거나 잘못된 응답이 왔습니다.\n\(reason)"
            case .FirebaseSignInError(let reason):
                return "ASFirebaseAuth.swift signIn() 에러: 익명 로그인에 실패했습니다.\n\(reason)"
            case .FirebaseSignOutError(let reason):
                return "ASFirebaseAuth.swift signOut() 에러: 로그아웃에 실패했습니다.\n\(reason)"
            case .FirebaseListenerError(let reason):
                return "ASFirebaseDatabase.swift addRoomListener() 에러: 해당 데이터베이스를 가져오는데 실패했습니다.\n\(reason ?? "")"
            case .responseError:
                return "ASNetworkManager.swift validate() 에러: 서버에서 응답이 없거나 잘못된 응답이 왔습니다."
        }
    }
}
