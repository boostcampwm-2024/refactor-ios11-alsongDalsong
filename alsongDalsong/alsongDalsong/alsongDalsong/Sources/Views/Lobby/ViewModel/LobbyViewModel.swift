import ASEntity
import ASRepositoryProtocol

class LobbyViewModel: ObservableObject, @unchecked Sendable {
    @Published var players: [Player]
    @Published var isHost: Bool = false
    @Published var canBeginGame: Bool = false
    @Published var host: Player?
    @Published var mode: Mode = .humming {
        didSet {
            if mode != oldValue {
                changeMode()
            }
        }
    }
    
    private var dataDownloadRepository: DataDownloadRepositoryProtocol
    let playerMaxCount: Int
    var roomNumber: String = ""

    init(playerMaxCount: Int = 4, players: [Player] = [], dataDownloadRepository: DataDownloadRepositoryProtocol) {
        self.playerMaxCount = playerMaxCount
        self.players = players
        self.dataDownloadRepository = dataDownloadRepository
    }
    
    func fetchData() {}
    func gameStart() async throws {}
    func getPlayerCount() -> Int { players.count }
    func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }
    func changeMode() {}
}
