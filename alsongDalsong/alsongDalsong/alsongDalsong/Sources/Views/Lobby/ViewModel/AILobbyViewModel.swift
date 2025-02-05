import ASEntity
import ASRepositoryProtocol

final class AILobbyViewModel: LobbyViewModel, @unchecked Sendable {
    private var playersRepository: PlayersRepositoryProtocol
    private var aiPlayer: [Player]
    
    init(dataDownloadRepository: DataDownloadRepositoryProtocol,
         playersRepository: PlayersRepositoryProtocol,
         aiImageURL: [URL]) {
        self.playersRepository = playersRepository

        aiPlayer = [Player(id: "0", avatarUrl: aiImageURL.first, nickname: "Helper1"),
                    Player(id: "1", avatarUrl: aiImageURL.last, nickname: "Helper2")]
        
        super.init(
            players: aiPlayer + (playersRepository.getTutorialPlayer().map { [$0] } ?? []),
            dataDownloadRepository: dataDownloadRepository
        )
    }
}
