import ASEntity
import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class SelectMusicViewModel: ObservableObject, @unchecked Sendable {
    @Published private(set) var searchList: [Music] = []
    @Published private(set) var isSearching: Bool = false
    @Published private(set) var dueTime: Date?
    @Published private(set) var selectedMusic: Music?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")

    @Published private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? playMusic() : stopMusic() }
    }
    
    @Published var searchTerm: String = ""
    
    private let playersRepository: PlayersRepositoryProtocol
    private let answersRepository: AnswersRepositoryProtocol
    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let dataDownloadRepository: DataDownloadRepositoryProtocol
    
    private let musicAPI = ASMusicAPI()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        playersRepository: PlayersRepositoryProtocol,
        answerRepository: AnswersRepositoryProtocol,
        gameStatusRepository: GameStatusRepositoryProtocol,
        dataDownloadRepository: DataDownloadRepositoryProtocol
    ) {
        self.playersRepository = playersRepository
        self.answersRepository = answerRepository
        self.gameStatusRepository = gameStatusRepository
        self.dataDownloadRepository = dataDownloadRepository
        bindGameStatus()
        bindSubmissionStatus()
        bindSearchTerm()
    }
    
    deinit {
        stopMusic()
    }
    
    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)
    }
    
    private func bindSubmissionStatus() {
        let playerPublisher = playersRepository.getPlayersCount()
        let answersPublisher = answersRepository.getAnswersCount()

        playerPublisher.combineLatest(answersPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playersCount, answersCount in
                let submitStatus = (submits: String(answersCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }
    
    private func bindSearchTerm() {
        $searchTerm
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] term in
                guard let self, !term.isEmpty else {
                    self?.resetSearchList()
                    return
                }
                Task { [weak self] in
                    try? await self?.searchMusic(text: term)
                }
            }
            .store(in: &cancellables)
    }
    
    func playMusic() {
        guard let data = musicData else { return }
        Task {
            await AudioHelper.shared.startPlaying(data, option: .full)
        }
    }
    
    func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
    
    func downloadArtwork(url: URL?) async -> Data? {
        guard let url else { return nil }
        return await dataDownloadRepository.downloadData(url: url)
    }
    
    func handleSelectedSong(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }
  
    func submitMusic() async throws {
        if let selectedMusic {
            do {
                _ = try await answersRepository.submitMusic(answer: selectedMusic)
            } catch {
                let error = ASErrors(type: .submitMusic, reason: error.localizedDescription, file: #file, line: #line)
                LogHandler.handleError(error)
                throw error
            }
        }
    }
 
    func searchMusic(text: String) async throws {
        do {
            if text.isEmpty { return }
            await updateIsSearching(with: true)
            let searchList = try await musicAPI.search(for: text)
            await updateSearchList(with: searchList)
            await updateIsSearching(with: false)
        } catch {
            let error = ASErrors(type: .searchMusicOnSelect, reason: error.localizedDescription, file: #file, line: #line)
            LogHandler.handleError(error)
            throw error
        }
    }
    
    @MainActor
    func randomMusic() async throws {
        do {
            selectedMusic = try await musicAPI.randomSong(from: "pl.u-aZb00o7uPlzMZzr")
        } catch {
            let error = ASErrors(type: .randomMusic, reason: error.localizedDescription, file: #file, line: #line)
            LogHandler.handleError(error)
            throw error
        }
    }
    
    func downloadMusic(url: URL) {
        Task {
            guard let musicData = await dataDownloadRepository.downloadData(url: url) else {
                return
            }
            await updateMusicData(with: musicData)
        }
    }
    
    private func beginPlaying() {
        guard let url = selectedMusic?.previewUrl else { return }
        downloadMusic(url: url)
    }
    
    func resetSearchList() {
        searchList = []
    }
    
    @MainActor
    private func updateMusicData(with musicData: Data) {
        self.musicData = musicData
    }
    
    @MainActor
    private func updateSearchList(with searchList: [Music]) {
        self.searchList = searchList
    }
    
    @MainActor
    private func updateIsSearching(with isSearching: Bool) {
        self.isSearching = isSearching
    }
    
    func cancelSubscriptions() {
        cancellables.removeAll()
    }
}
