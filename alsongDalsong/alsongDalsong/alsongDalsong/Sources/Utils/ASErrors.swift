import Foundation

struct ASErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    enum ErrorType {
        case analyze, startRecording, playFull, playPartial
        case leaveRoom
        case submitHumming
        case fetchAvatars
        case gameStart, changeMode
        case authorizeAppleMusic, joinRoom, createRoom
        case submitRehumming
        case changeRecordOrder, navigateToLobby
        case submitMusic, searchMusicOnSelect, randomMusic
        case searchMusicOnSubmit, submitAnswer
    }

    var errorDescription: String? {
        return "[\(file):\(line)] \(type) 에러: \n\(reason)"
    }
}
