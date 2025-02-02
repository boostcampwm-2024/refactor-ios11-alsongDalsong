import Foundation

struct ASMusicErrors: LocalizedError {
    let type: ErrorType
    let reason: String
    let file: String
    let line: Int

    enum ErrorType {
        case notAuthorized
        case search
        case playListHasNoSongs
    }

    var errorDescription: String? {
        return "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(type) 에러: \n\(reason)"
    }
}

