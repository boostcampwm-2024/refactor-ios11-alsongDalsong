import Foundation

public struct Music: Codable, Equatable, Identifiable, Sendable, Hashable {
    public var id: String?
    public var title: String?
    public var artist: String?
    public var artworkUrl: URL?
    public var previewUrl: URL?
    public var artworkBackgroundColor: String?

    public init() {}

    public init(title: String, artist: String) {
        self.title = title
        self.artist = artist
    }
  
    public init(id: String, title: String?, artist: String?, artworkUrl: URL?, previewUrl: URL?, artworkBackgroundColor: String?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
        self.previewUrl = previewUrl
        self.artworkBackgroundColor = artworkBackgroundColor
    }
}

extension Music {
    public init(_ record: ASEntity.Record) {
        self.previewUrl = record.fileUrl
    }
}

extension Music {
    public static let musicStub1 = Music(
        id: "1",
        title: "네 번호가 뜨는 일",
        artist: "이예준",
        artworkUrl: URL(string:"https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/94/d1/27/94d12730-39c3-53a9-fdc3-52ca01e33d79/cover_KM0016750_1.jpg/300x300bb.jpg"),
        previewUrl: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview113/v4/05/c7/fe/05c7fe7b-4871-5dde-9f13-46bada057623/mzaf_8929995540220645309.plus.aac.p.m4a"),
        artworkBackgroundColor: "92897a"
    )
    public static let musicStub2 = Music(title: "그거 아세요?", artist: "이혁")
    public static let musicStub3 = Music(title: "으아~", artist: "김흥국")
    public static let musicStub4 = Music(title: "이브, 프시케 그리고 푸른 수염의 아내", artist: "르세라핌")
}
