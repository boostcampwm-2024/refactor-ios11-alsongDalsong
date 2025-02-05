import ASEntity
import Combine
import Foundation

final class HummingResultTutorialViewModel: ObservableObject {
    @Published var result: Result = (nil, [], nil)
    @Published var resultPhase: ResultPhase = .none
    @Published var isTutorialFinished = false
    
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func updateResult() {
        Task {
            let answer = Answer(player: .playerStub1, music: TutorialData.superShy)
            let records: [ASEntity.Record] = [.recordStub1_1]
            let submit = Answer(player: .playerStub2, music: TutorialData.loser)
            
            let mappedAnswer = await mapAnswer(answer)
            let mappedRecords = await mapRecords(records)
            let mappedSubmit = await mapAnswer(submit)
            
            result = (mappedAnswer, mappedRecords, mappedSubmit)
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
                isTutorialFinished = true
                
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
                        self.updateResultPhase()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    private func startPlaying() async {
        let audioData = resultPhase.audioData(result)
        let playOption = resultPhase.playOption
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
            let recordAmplitudes = await AudioHelper.shared.analyze(with: recordData ?? Data())
            LogHandler.handleDebug(recordAmplitudes)
            let playerName = record.player?.nickname
            let playerAvatarData = await getAvatarData(url: record.player?.avatarUrl)
            mappedRecords.append(MappedRecord(recordData, recordAmplitudes, playerName, playerAvatarData))
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
}
