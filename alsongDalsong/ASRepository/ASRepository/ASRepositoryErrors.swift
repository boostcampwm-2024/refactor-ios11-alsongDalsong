import Foundation

struct ASRepositoryErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    enum ErrorType {
        case submitMusic
        case getAvatarUrls
        case postRecording, postResetGame
        case uploadRecording
        case createRoom, joinRoom, leaveRoom, startGame, changeMode, changeRecordOrder, resetGame, sendRequest
        case submitAnswer
    }

    var errorDescription: String? {
        return "[\(file):\(line)] \(type) 에러: \n\(reason)"
    }
}
