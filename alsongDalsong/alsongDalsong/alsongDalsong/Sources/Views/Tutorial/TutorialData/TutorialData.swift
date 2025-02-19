import ASEntity
import Foundation

enum TutorialData {
    static let superShy = Music(
        id: "1692686518",
        title: "Super Shy",
        artist: "뉴진스",
        artworkUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/63/e5/e2/63e5e2e4-829b-924d-a1dc-8058a1d69bd4/196922462702_Cover.jpg/300x300bb.jpg"),
        previewUrl: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/f0/c3/73/f0c37318-0928-f8ce-c008-f671f6435067/mzaf_2056463446400078652.plus.aac.p.m4a"),
        artworkBackgroundColor: "#8FC1E2"
    )
    
    static let loser = Music(
        id: "1314236146",
        title: "LOSER",
        artist: "BIGBANG",
        artworkUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/1f/7e/2a/1f7e2ae3-45aa-430f-e95d-6b2aff4e0b4c/BIGBANG_M_ONLINE.jpg/300x300bb.jpg"),
        previewUrl: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/dc/2f/21/dc2f21a7-b30a-2056-751b-76927ae9b3bb/mzaf_12471769798914044064.plus.aac.p.m4a"),
        artworkBackgroundColor: "#BA1718"
    )

    static let theMoonOfSeoul = Music(
        id: "1267207255",
        title: "서울의 달",
        artist: "김건모",
        artworkUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/66/20/bd/6620bd8d-6f41-f0fd-2842-696f1ed3086b/8809522647272.jpg/300x300bb.jpg"),
        previewUrl: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/86/0b/fd/860bfd34-9062-72c7-7788-9976c6210a3e/mzaf_5174102604307340089.plus.aac.p.m4a"),
        artworkBackgroundColor: "#2A1921"
    )

    static let aiLoser = Music(id: "aiLoser", title: "AI의 허밍을 듣고 따라 불러보세요", artist: "", artworkUrl: URL(string: "https://blog.kakaocdn.net/dn/bxdtFz/btqAfmWl2Zl/anXjXtfAfFUC0OOgkIcMWk/img.jpg"), previewUrl: Record.AIRecord.loser.fileUrl, artworkBackgroundColor: nil)
    static let aiSuperShy = Music(Record.AIRecord.superShy)
}
