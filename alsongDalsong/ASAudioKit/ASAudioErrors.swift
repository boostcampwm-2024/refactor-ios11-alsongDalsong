import Foundation

enum ASAudioErrors: Error, LocalizedError {
    case startPlayingError(reason: String)
    case getDurationError(reason: String)
    case configureAudioSessionError(reason: String)
    case startRecordingError(reason: String)
    case analyzeError(reason: String)

    var errorDescription: String? {
        switch self {
        case .startPlayingError(let reason):
            return "ASAudioPlayer.swift startPlaying() 에러: 오디오 객체 생성에 실패했습니다.\n\(reason)"
        case .getDurationError(let reason):
            return "ASAudioPlayer.swift getDuration() 에러: 오디오 객체 생성에 실패했습니다.\n\(reason)"
        case .configureAudioSessionError(let reason):
            return "confitureAudioSession() 에러: 세션 설정에 실패했습니다.\n\(reason)"
        case .startRecordingError(let reason):
            return "ASAudioRecorder.swift startRecording() 에러: 오디오 레코더 객체 생성에 실패했습니다.\n\(reason)"
        case .analyzeError(let reason):
            return "ASAudioAnalyzer.swift analyze() 에러: 오디오 분석에 실패했습니다.\n\(reason)"
        }
    }
}
