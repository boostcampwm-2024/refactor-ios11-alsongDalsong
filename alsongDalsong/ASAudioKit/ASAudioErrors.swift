import Foundation

struct ASAudioErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    enum ErrorType {
        case analyze
        case startPlaying, getDuration
        case configureAudioSession
        case startRecording
    }

    var errorDescription: String? {
        return "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(type) 에러: \n\(reason)"
    }
}
