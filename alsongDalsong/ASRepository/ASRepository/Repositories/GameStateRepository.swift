import ASEntity
import Combine
import Foundation
import ASRepositoryProtocol

final class GameStateRepository: GameStateRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    func getGameState() -> AnyPublisher<ASEntity.GameState?, Never> {
        Publishers.CombineLatest4(mainRepository.mode, mainRepository.recordOrder, mainRepository.status, mainRepository.round)
            .receive(on: DispatchQueue.main)
            .map { mode, recordOrder, status, round in
                guard let mode, let round, let players = self.mainRepository.players.value else { return nil }
                return ASEntity.GameState(mode: mode, recordOrder: recordOrder, status: status, round: round, players: players)
            }
            .eraseToAnyPublisher()
    }
}
