import Foundation

enum ASRepositoryErrors: Error, LocalizedError {
    case submitMusicError(reason: String)
    case getAvatarUrlsError(reason: String)
    case postRecordingError(reason: String)
    case postResetGameError(reason: String)
    case uploadRecordingError(reason: String)
    case createRoomError(reason: String)
    case joinRoomError(reason: String)
    case leaveRoomError(reason: String)
    case startGameError(reason: String)
    case changeModeError(reason: String)
    case changeRecordOrderError(reason: String)
    case resetGameError(reason: String)
    case sendRequestError(reason: String)
    case submitAnswerError(reason: String)


    var errorDescription: String? {
        switch self {
        case .submitMusicError(let reason):
            return "AnswersRepository.swift submitMusic() 에러: \n\(reason)"
        case .getAvatarUrlsError(let reason):
            return "AvatarRepository.swift getAvatarUrls() 에러: \n\(reason)"
        case .postRecordingError(let reason):
            return "MainRepository.swift postRecording() 에러: \n\(reason)"
        case .postResetGameError(let reason):
            return "MainRepository.swift postResetGame() 에러: \n\(reason)"
        case .uploadRecordingError(let reason):
            return "RecordsRepository.swift uploadRecording() 에러: \n\(reason)"
        case .createRoomError(let reason):
            return "RoomActionRepository.swift createRoom() 에러: \n\(reason)"
        case .joinRoomError(let reason):
            return "RoomActionRepository.swift joinRoom() 에러: \n\(reason)"
        case .leaveRoomError(let reason):
            return "RoomActionRepository.swift leaveRoom() 에러: \n\(reason)"
        case .startGameError(let reason):
            return "RoomActionRepository.swift startGame() 에러: \n\(reason)"
        case .changeModeError(let reason):
            return "RoomActionRepository.swift changeMode() 에러: \n\(reason)"
        case .changeRecordOrderError(let reason):
            return "RoomActionRepository.swift changeRecordOrder() 에러: \n\(reason)"
        case .resetGameError(let reason):
            return "RoomActionRepository.swift resetGame() 에러: \n\(reason)"
        case .sendRequestError(let reason):
            return "RoomActionRepository.swift sendRequest() 에러: \n\(reason)"
        case .submitAnswerError(let reason):
            return "SubmitsRepository.swift submitAnswer() 에러: \n\(reason)"
        }
    }
}
