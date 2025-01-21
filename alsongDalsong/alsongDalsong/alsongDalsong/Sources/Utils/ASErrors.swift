import Foundation

enum ASErrors: Error, LocalizedError {
    case analyzeError(reason: String)
    case startRecordingError(reason: String)
    case playFullError(reason: String)
    case playPartialError(reason: String)
    case leaveRoomError(reason: String)
    case submitHummingError(reason: String)
    case fetchAvatarsError(reason: String)
    case gameStartError(reason: String)
    case changeModeError(reason: String)
    case authorizeAppleMusicError(reason: String)
    case joinRoomError(reason: String)
    case createRoomError(reason: String)
    case submitRehummingError(reason: String)
    case changeRecordOrderError(reason: String)
    case navigateToLobbyError(reason: String)
    case submitMusicError(reason: String)
    case searchMusicOnSelectError(reason: String)
    case randomMusicError(reason: String)
    case searchMusicOnSubmitError(reason: String)
    case submitAnswerError(reason: String)

    var errorDescription: String? {
        switch self {
        case .analyzeError(let reason):
            return "AudioHelper.swift analyze() 에러: \n\(reason)"
        case .startRecordingError(let reason):
            return "AudioHelper.swift startRecording() 에러: \n\(reason)"
        case .playFullError(let reason):
            return "AudioHelper.swift play(option: .full) 에러: \n\(reason)"
        case .playPartialError(let reason):
            return "AudioHelper.swift play(option: .partial) 에러: \n\(reason)"
        case .leaveRoomError(let reason):
            return "GameNavigationController.swift leaveRoom() 에러: \n\(reason)"
        case .submitHummingError(let reason):
            return "HummingViewModel.swift submitHumming() 에러: \n\(reason)"
        case .fetchAvatarsError(let reason):
            return "LoadingViewModel.swift fetchAvatars() 에러: \n\(reason)"
        case .gameStartError(let reason):
            return "LobbyViewModel.swift gameStart() 에러: \n\(reason)"
        case .changeModeError(let reason):
            return "LobbyViewModel.swift changeMode() 에러: \n\(reason)"
        case .authorizeAppleMusicError(let reason):
            return "OnboardingViewModel.swift authorizeAppleMusic() 에러: \n\(reason)"
        case .joinRoomError(let reason):
            return "OnboardingViewModel.swift joinRoom() 에러: \n\(reason)"
        case .createRoomError(let reason):
            return "OnboardingViewModel.swift createRoom() 에러: \n\(reason)"
        case .submitRehummingError(let reason):
            return "RehummingViewModel.swift submitHumming() 에러: \n\(reason)"
        case .changeRecordOrderError(let reason):
            return "HummingResultViewModel.swift changeRecordOrder() 에러: \n\(reason)"
        case .navigateToLobbyError(let reason):
            return "HummingResultViewModel.swift navigateToLobby() 에러: \n\(reason)"
        case .submitMusicError(let reason):
            return "SelectMusicViewModel.swift submitMusic() 에러: \n\(reason)"
        case .searchMusicOnSelectError(let reason):
            return "SelectMusicViewModel.swift searchMusic() 에러: \n\(reason)"
        case .randomMusicError(let reason):
            return "SelectMusicViewModel.swift randomMusic() 에러: \n\(reason)"
        case .searchMusicOnSubmitError(let reason):
            return "SubmitAnswerViewModel.swift searchMusic() 에러: \n\(reason)"
        case .submitAnswerError(let reason):
            return "SubmitAnswerViewModel.swift submitAnswer() 에러: \n\(reason)"
        }
    }
}
