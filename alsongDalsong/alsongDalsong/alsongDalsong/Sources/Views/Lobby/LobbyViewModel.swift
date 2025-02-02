import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

final class LobbyViewModel: ObservableObject, @unchecked Sendable {
    private var playersRepository: PlayersRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var dataDownloadRepository: DataDownloadRepositoryProtocol

    let playerMaxCount = 4
    private(set) var roomNumber: String = ""
    @Published var players: [Player] = []
    @Published var host: Player?
    @Published var isHost: Bool = false
    @Published var canBeginGame: Bool = false
    @Published var mode: Mode = .humming {
        didSet {
            if mode != oldValue {
                changeMode()
            }
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    init(playersRepository: PlayersRepositoryProtocol,
         roomInfoRepository: RoomInfoRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         dataDownloadRepository: DataDownloadRepositoryProtocol)
    {
        self.playersRepository = playersRepository
        self.roomActionRepository = roomActionRepository
        self.roomInfoRepository = roomInfoRepository
        self.dataDownloadRepository = dataDownloadRepository
        fetchData()
    }

    func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }

    func fetchData() {
        playersRepository.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] players in
                self?.players = players
            }
            .store(in: &cancellables)

        playersRepository.getHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] host in
                self?.host = host
            }
            .store(in: &cancellables)

        roomInfoRepository.getMode()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                guard let isHost = self?.isHost else { return }
                if !isHost {
                    self?.mode = mode
                }
            }
            .store(in: &cancellables)

        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                self?.roomNumber = roomNumber
            }
            .store(in: &cancellables)

        playersRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.isHost = isHost
            }
            .store(in: &cancellables)

        playersRepository.isHost().combineLatest(playersRepository.getPlayersCount())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost, playerCount in
                self?.canBeginGame = isHost && playerCount > 1
            }
            .store(in: &cancellables)
    }

    func gameStart() async throws {
        do {
            _ = try await roomActionRepository.startGame(roomNumber: roomNumber)
        } catch {
            let error = ASErrors(type: .gameStart, reason: error.localizedDescription, file: #file, line: #line)
            LogHandler.handleError(error.localizedDescription)
            throw error
        }
    }

    func changeMode() {
        Task {
            do {
                if isHost {
                    _ = try await self.roomActionRepository.changeMode(roomNumber: roomNumber, mode: mode)
                }
            } catch {
                let error = ASErrors(type: .changeMode, reason: error.localizedDescription, file: #file, line: #line)
                LogHandler.handleError(error)
            }
        }
    }
}
