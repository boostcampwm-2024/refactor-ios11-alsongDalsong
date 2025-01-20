import ASEntity
import ASRepositoryProtocol
import Combine

public final class PlayersMockRepository: PlayersRepositoryProtocol {
    private let playersStub = [
        Player.playerStub1,
        Player.playerStub2,
        Player.playerStub3,
        Player.playerStub4
    ]
    private let playersPublisher = CurrentValueSubject<[Player], Never>([])
    
    public init() {
        playersPublisher.send(playersStub)
    }
    
    public func getPlayers() -> AnyPublisher<[Player], Never> {
        playersPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getPlayersCount() -> AnyPublisher<Int, Never> {
        playersPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map(\.count)
            .eraseToAnyPublisher()
    }
    
    public func getHost() -> AnyPublisher<Player, Never> {
        Just(Player.playerStub1)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func isHost() -> AnyPublisher<Bool, Never> {
        Just(true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
