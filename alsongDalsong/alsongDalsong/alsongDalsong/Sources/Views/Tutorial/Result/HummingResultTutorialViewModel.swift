import ASAIKit
import ASEntity
import ASMusicKit
import Combine
import Foundation

final class HummingResultTutorialViewModel: ObservableObject {
    @Published var result: Result = (nil, [], nil)
    @Published var resultPhase: ResultPhase = .none
    @Published var isTutorialFinished = false
    
    private var cancellables = Set<AnyCancellable>()

    private var totalResult: [Result] = []
    
    private let tutorialPlayers: [TutorialPlayer?]
    private lazy var players: [Player] = tutorialPlayers.compactMap {
        Player(
            id: UUID().uuidString,
            avatarUrl: $0?.avatarURL,
            nickname: $0?.name,
            order: nil
        )
    }
    
    init(player: TutorialPlayer?, aiPlayer1: TutorialPlayer?, aiPlayer2: TutorialPlayer?) {
        self.tutorialPlayers = [player, aiPlayer1, aiPlayer2]
    }
    
    @MainActor
    func setDatasource() {
        Task {
            guard let tutorialPlayers = tutorialPlayers as? [TutorialPlayer] else { return }
            let count = tutorialPlayers.count
            for i in 0 ..< count {
                let previousIndex = (i - 1 + count) % count
                let beforePreviousIndex = (i - 2 + count) % count
                
                let answer = ASEntity.Answer(
                    player: players[i],
                    music: tutorialPlayers[i].selectedMusic
                )
                let humming = ASEntity.Record(
                    player: players[i],
                    recordOrder: nil,
                    fileUrl: tutorialPlayers[i].hummingURL
                )
                
                let rehumming = ASEntity.Record(
                    player: players[previousIndex],
                    recordOrder: nil,
                    fileUrl: tutorialPlayers[previousIndex].rehummingURL
                )
                let submit: Answer
                // Player인 경우
                if let unwrappedSubmit = tutorialPlayers[beforePreviousIndex].submittedMusic {
                    submit = ASEntity.Answer(
                        player: players[beforePreviousIndex],
                        music: unwrappedSubmit
                    )
                } else {
                    submit = await makeAISubmit(
                        url: tutorialPlayers[beforePreviousIndex].rehummingURL,
                        player: players[beforePreviousIndex]
                    )
                }
                let mappedAnswer: MappedAnswer = await mapAnswer(answer)
                let mappedRecords: [MappedRecord] = await mapRecords([humming, rehumming])
                let mappedSubmit: MappedAnswer = await mapAnswer(submit)
                
                totalResult.append((mappedAnswer, mappedRecords, mappedSubmit))
            }
            updateResult()
        }
    }

    @MainActor
    func updateResult() {
        Task {
            guard !totalResult.isEmpty else {
                return
            }
            let currentResult = totalResult.removeFirst()
            result = currentResult
            updateResultPhase()
        }
    }
    
    @MainActor
    private func updateResultPhase() {
        Task {
            switch resultPhase {
            case .answer:
                resultPhase = .record(0)
                await startPlaying()
                
            case let .record(count):
                if result.records.count - 1 == count { resultPhase = .submit }
                else { resultPhase = .record(count + 1) }
                await startPlaying()
                
            case .submit:
                resultPhase = .none
                await startPlaying()
                if totalResult.isEmpty { isTutorialFinished = true }

            case .none:
                resultPhase = .answer
                await startPlaying()
            }
        }
    }
    
    @MainActor
    func bindAudio() {
        Task {
            await AudioHelper.shared.playerStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _, isPlaying in
                    guard let self else { return }
                    if !isPlaying {
                        updateResultPhase()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    private func startPlaying() async {
        let playOption = resultPhase.playOption
        guard let audioData = resultPhase.audioData(result) else {
            // Data가 nil인 경우, MIDI 파일로 간주하여 재생
            guard let url = resultPhase.getMIDIURL(result) else {
                // MIDI 파일이 아닌 경우, 오디오 데이터가 이상 한 경우로 간주하고 재생하지 않음.
                // 에러처리가 필요할 듯?
                return
            }
            await AudioHelper.shared.startPlayingMIDI(url, option: playOption)
            return
        }
        await AudioHelper.shared.startPlaying(audioData, option: playOption)
    }
    
    private func mapAnswer(_ answer: Answer) async -> MappedAnswer {
        let artworkData = await getArtworkData(answer.music)
        let previewData = await getPreviewData(answer.music)
        let title = answer.music?.title
        let artist = answer.music?.artist
        let playerName = answer.player?.nickname
        let playerAvatarData = await getAvatarData(url: answer.player?.avatarUrl)
        return MappedAnswer(artworkData, previewData, title, artist, playerName, playerAvatarData)
    }

    private func mapRecords(_ records: [ASEntity.Record]) async -> [MappedRecord] {
        var mappedRecords = [MappedRecord]()

        for record in records {
            let recordData = await getRecordData(url: record.fileUrl)
            let playerName = record.player?.nickname
            let playerAvatarData = await getAvatarData(url: record.player?.avatarUrl)
            // MIDI 파일인지 에 따라 파형 함수 및 MappedRecord 생성이 달라짐.
            // 이후 노래를 재생할 때, MIDI 파일인지 검사하는 로직을 추가하여 재생 방식을 다르게 해야함.
            if let url = record.fileUrl, url.pathExtension == "mid" {
                let recordAmplitudes = await AudioHelper.shared.analyze(with: url)
                mappedRecords.append(MappedRecord(url, recordAmplitudes, playerName, playerAvatarData))
            } else {
                let recordAmplitudes = await AudioHelper.shared.analyze(with: recordData ?? Data())
                mappedRecords.append(MappedRecord(recordData, recordAmplitudes, playerName, playerAvatarData))
            }
        }

        return mappedRecords
    }

    private func getAvatarData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }
    
    private func getArtworkData(_ music: Music?) async -> Data? {
        guard let url = music?.artworkUrl else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }

    private func getPreviewData(_ music: Music?) async -> Data? {
        guard let url = music?.previewUrl else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }
    
    private func getRecordData(url: URL?) async -> Data? {
        guard let url else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }
    
    private func makeAISubmit(url: URL?, player: Player) async -> Answer {
        guard let url else { return Answer(player: .playerStub2, music: TutorialData.loser) }
        guard let result = await ASAIAnalyzer.analyzeAudioURL(audioURL: url, mode: .full()) else {
            return ASEntity.Answer(
                player: player,
                music: TutorialData.loser
            )
        }
        let music = try? await ASMusicAPI().search(for: result.bestClassification).first
        return ASEntity.Answer(
            player: player,
            music: music
        )
    }
}

private extension ResultPhase {
    func getMIDIURL(_ result: Result) -> URL? {
        switch self {
        case .answer: nil
        case let .record(count): result.records[count].midiURL
        case .submit: nil
        case .none: nil
        }
    }
}
