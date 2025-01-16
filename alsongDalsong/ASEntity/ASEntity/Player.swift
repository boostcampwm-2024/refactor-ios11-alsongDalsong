import Foundation

public struct Player: Codable, Equatable, Identifiable, Sendable, Hashable {
    public var id: String
    public var avatarUrl: URL?
    public var nickname: String?
    public var order: Int?
    
    public init(
        id: String,
        avatarUrl: URL? = nil,
        nickname: String? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.avatarUrl = avatarUrl
        self.nickname = nickname
        self.order = order
    }
}

extension Player {
    public static let playerStub1: Player = Player(id: "0", avatarUrl: nil, nickname: "Tltlbo", order: 0)
    public static let playerStub2: Player = Player(id: "1", avatarUrl: nil, nickname: "Sonny", order: 1)
    public static let playerStub3: Player = Player(id: "2", avatarUrl: nil, nickname: "Moral-life", order: 2)
    public static let playerStub4: Player = Player(id: "3", avatarUrl: nil, nickname: "Sang₩", order: 3)
}
