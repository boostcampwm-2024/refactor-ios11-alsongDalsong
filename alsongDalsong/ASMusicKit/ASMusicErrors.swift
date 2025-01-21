import Foundation

enum ASMusicErrors: Error, LocalizedError {
    case notAuthorized
    case searchError(reason: String)
    case playListHasNoSongs

    var errorDescription: String? {
        switch self {
            case .notAuthorized:
                return "ASMusicAPI.swift search() 에러: 애플 뮤직에 접근하는 권한이 없습니다."
            case .searchError(let reason):
                return "ASMusicAPI.swift search() 에러: 노래 검색 중 오류가 발생했습니다.\n\(reason)"
            case .playListHasNoSongs:
                return "ASMusicAPI.swift randomSong() 에러: 플레이리스트에 노래가 없습니다."
        }
    }
}
