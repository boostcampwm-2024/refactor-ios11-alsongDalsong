import Foundation
import Testing

struct ASAudioPlayerTests {
    private let player: ASAudioPlayer
    private let testMusic: Data

    init() async throws {
        player = ASAudioPlayer()
        let bundle = Bundle(identifier: "kr.codesquad.boostcamp9.alsongDalsong.ASAudioKitTests")
        let url = try #require(bundle?.url(forResource: "PlayTestDrum", withExtension: "wav"))
        testMusic = try Data(contentsOf: url)
    }

    @Test("재생 시작 성공") func startPlaying() async throws {
        await player.startPlaying(data: testMusic, option: .full)

        #expect(await player.isPlaying())
    }

    @Test("제한된 시간 동안 재생 시작 성공") func startPlayingWithTimeLimit() async {
        await player.startPlaying(data: testMusic, option: .partial(time: 6))

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            Task {
                #expect(await player.isPlaying() == false)
            }
        }
        
        #expect(await player.isPlaying())
    }
}
