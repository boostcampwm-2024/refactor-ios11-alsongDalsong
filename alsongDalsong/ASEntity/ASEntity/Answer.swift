import Foundation

public struct Answer: Codable, Equatable, Sendable, Hashable {
    public var player: Player?
    public var music: Music?
    
    public init(player: Player?, music: Music?) {
        self.player = player
        self.music = music
    }
}

extension Answer {
    public static let answerStub1 = Answer(player: Player.playerStub1,
                                           music: Music.musicStub1)
    public static let answerStub2 = Answer(player: Player.playerStub2,
                                           music: Music.musicStub2)
    public static let answerStub3 = Answer(player: Player.playerStub3,
                                           music: Music.musicStub3)
    public static let answerStub4 = Answer(player: Player.playerStub4,
                                           music: Music.musicStub4)
}
