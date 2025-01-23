import ASEntity
import ASRepositoryProtocol
import Combine

public final class GameStateMockRepository: GameStateRepositoryProtocol {
    private let gameStatePublisher = CurrentValueSubject<ASEntity.GameState?, Never>(nil)

    public init(state: GameState) {
        switch state.mode {
        case .humming:
            gameStatePublisher.send(state)
        default:
            break
        }
    }

    public func getGameState() -> AnyPublisher<ASEntity.GameState?, Never> {
        gameStatePublisher
            .eraseToAnyPublisher()
    }
}
