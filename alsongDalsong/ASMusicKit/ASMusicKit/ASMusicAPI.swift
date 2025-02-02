import ASEntity
import Foundation
import MusicKit

public struct ASMusicAPI {
    public init() {}

    /// MusicKit을 통해 Apple Music의 노래를 검색합니다.
    /// - Parameters:
    ///   - text: 검색 요청을 보낼 검색어
    ///   - maxCount: 검색해서 찾아올 음악의 갯수 기본값 설정은 25
    /// - Returns: Music의 배열
    public func search(for text: String, _ maxCount: Int = 10, _ offset: Int = 0) async throws -> [Music] {
        let status = await MusicAuthorization.request()
        switch status {
            case .authorized:
                do {
                    var request = MusicCatalogSearchSuggestionsRequest(term: text, includingTopResultsOfTypes: [Song.self])

                    request.limit = maxCount

                    let result = try await request.response()

                    if !result.topResults.isEmpty {
                        let music = result.topResults.compactMap { topResult -> ASEntity.Music? in
                            if case .song(let song) = topResult {
                                return ASEntity.Music(
                                    id: song.id.rawValue,
                                    title: song.title,
                                    artist: song.artistName,
                                    artworkUrl: song.artwork?.url(width: 300, height: 300),
                                    previewUrl: song.previewAssets?.first?.url,
                                    artworkBackgroundColor: song.artwork?.backgroundColor?.toHex()
                                )
                            }
                            return nil
                        }
                        return music
                    } else {
                        var request = MusicCatalogSearchRequest(term: text, types: [Song.self])
                        request.offset = offset
                        request.limit = maxCount

                        let result = try await request.response()
                        let music = result.songs.map { song in
                            ASEntity.Music(
                                id: song.id.rawValue,
                                title: song.title,
                                artist: song.artistName,
                                artworkUrl: song.artwork?.url(width: 300, height: 300),
                                previewUrl: song.previewAssets?.first?.url,
                                artworkBackgroundColor: song.artwork?.backgroundColor?.toHex()
                            )
                        }
                        return music
                    }
                } catch {
                    throw ASMusicErrors(type: .search, reason: error.localizedDescription, file: #file, line: #line)
                }
            default:
            throw ASMusicErrors(type: .notAuthorized, reason: "", file: #file, line: #line)
        }
    }

    public func randomSong(from playlistId: String) async throws -> ASEntity.Music {
        let status = await MusicAuthorization.request()
        switch status {
            case .authorized:
                do {
                    let request = MusicCatalogResourceRequest<MusicKit.Playlist>(matching: \.id, equalTo: MusicItemID(rawValue: playlistId))
                    let playlistResponse = try await request.response()
                    let playlist = playlistResponse.items.first!

                    let playlistWithTrack = try await playlist.with([.tracks])
                    guard let tracks = playlistWithTrack.tracks else {
                        throw ASMusicErrors(type: .playListHasNoSongs, reason: "", file: #file, line: #line)
                    }

                    if let song = tracks.randomElement() {
                        return ASEntity.Music(
                            id: song.id.rawValue,
                            title: song.title,
                            artist: song.artistName,
                            artworkUrl: song.artwork?.url(width: 300, height: 300),
                            previewUrl: song.previewAssets?.first?.url,
                            artworkBackgroundColor: song.artwork?.backgroundColor?.toHex()
                        )
                    }
                } catch {
                    throw ASMusicErrors(type: .search, reason: "", file: #file, line: #line)
                }
            default:
            throw ASMusicErrors(type: .notAuthorized, reason: "", file: #file, line: #line)
        }
        return ASEntity.Music(id: "nil", title: nil, artist: nil, artworkUrl: nil, previewUrl: nil, artworkBackgroundColor: nil)
    }
}
