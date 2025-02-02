import ASEntity
import ASMusicKit
import ASRepositoryProtocol
import Combine
import Foundation

final class SubmitAnswerViewModel: ObservableObject, @unchecked Sendable {
    @Published private(set) var searchList: [Music] = []
    @Published private(set) var selectedMusic: Music?
    @Published private(set) var isSearching: Bool = false
    @Published private(set) var dueTime: Date?
    @Published private(set) var submissionStatus: (submits: String, total: String) = ("0", "0")
    @Published private(set) var music: Music?
    @Published private(set) var musicData: Data? {
        didSet { isPlaying = true }
    }

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? playingMusic() : stopMusic() }
    }

    @Published var searchTerm: String = ""

    private let gameStatusRepository: GameStatusRepositoryProtocol
    private let playersRepository: PlayersRepositoryProtocol
    private let recordsRepository: RecordsRepositoryProtocol
    private let submitsRepository: SubmitsRepositoryProtocol
    private let dataDownloadRepository: DataDownloadRepositoryProtocol

    private let musicAPI = ASMusicAPI()
    private var cancellables: Set<AnyCancellable> = []

    init(
        gameStatusRepository: GameStatusRepositoryProtocol,
        playersRepository: PlayersRepositoryProtocol,
        recordsRepository: RecordsRepositoryProtocol,
        submitsRepository: SubmitsRepositoryProtocol,
        dataDownloadRepository: DataDownloadRepositoryProtocol
    ) {
        self.gameStatusRepository = gameStatusRepository
        self.playersRepository = playersRepository
        self.recordsRepository = recordsRepository
        self.submitsRepository = submitsRepository
        self.dataDownloadRepository = dataDownloadRepository
        bindGameStatus()
        bindSearchTerm()
    }

    deinit {
        stopMusic()
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

    private func bindRecord(on recordOrder: UInt8) {
        recordsRepository.getHumming(on: recordOrder)
            .sink { [weak self] record in
                guard let record else { return }
                self?.music = Music(record)
            }
            .store(in: &cancellables)
    }

    private func bindGameStatus() {
        gameStatusRepository.getDueTime()
            .sink { [weak self] newDueTime in
                self?.dueTime = newDueTime
            }
            .store(in: &cancellables)

        gameStatusRepository.getRecordOrder()
            .sink { [weak self] newRecordOrder in
                self?.bindRecord(on: newRecordOrder)
                self?.bindSubmissionStatus()
            }
            .store(in: &cancellables)
    }

    private func bindSubmissionStatus() {
        let playerPublisher = playersRepository.getPlayersCount()
        let submitsPublisher = submitsRepository.getSubmitsCount()

        playerPublisher.combineLatest(submitsPublisher)
            .sink { [weak self] playersCount, submitsCount in
                let submitStatus = (submits: String(submitsCount), total: String(playersCount))
                self?.submissionStatus = submitStatus
            }
            .store(in: &cancellables)
    }

    func playingMusic() {
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

    func downloadMusic(url: URL) {
        Task {
            guard let musicData = await dataDownloadRepository.downloadData(url: url) else {
                return
            }
            await updateMusicData(with: musicData)
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
            let error = ASErrors(type: .searchMusicOnSubmit, reason: error.localizedDescription, file: #file, line: #line)
            LogHandler.handleError(error)
            throw error
        }
    }

    func handleSelectedMusic(with music: Music) {
        selectedMusic = music
        beginPlaying()
    }

    private func beginPlaying() {
        guard let previewUrl = selectedMusic?.previewUrl else { return }
        downloadMusic(url: previewUrl)
    }

    func submitAnswer() async throws {
        guard let selectedMusic else { return }
        do {
            let _ = try await submitsRepository.submitAnswer(answer: selectedMusic)
        } catch {
            let error = ASErrors(type: .submitAnswer, reason: error.localizedDescription, file: #file, line: #line)
            LogHandler.handleError(error)
            throw error
        }
    }

    // MARK: - 이부분 부터 RehummingViewModel

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
