import ASEntity
import Combine
import Foundation
import ASLogKit
import ASRepositoryProtocol

final class RecordsRepository: RecordsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    init(mainRepository: MainRepositoryProtocol) {
        self.mainRepository = mainRepository
    }

    func getRecordsCount(on recordOrder: UInt8) -> AnyPublisher<Int, Never> {
       return mainRepository.records
            .compactMap { $0 }
            .map { records in
                return records.filter { Int($0.recordOrder ?? 0) == recordOrder }
            }
            .map {
                return $0.count
            }
            .eraseToAnyPublisher()
    }

    func getHumming(on recordOrder: UInt8) -> AnyPublisher<ASEntity.Record?, Never> {
        let recordsPublisher = mainRepository.records
        let playersPublisher = mainRepository.players

        return recordsPublisher
            .combineLatest(playersPublisher)
            .map { [weak self] records, players -> ASEntity.Record? in
                self?.findRecord(
                    records: records,
                    players: players,
                    recordOrder: recordOrder
                )
            }
            .eraseToAnyPublisher()
    }

    func uploadRecording(_ record: Data) async throws -> Bool {
        do {
            return try await mainRepository.postRecording(record)
        } catch {
            throw ASRepositoryErrors(type: .uploadRecording, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
    
    private func findRecord(records: [ASEntity.Record]?,
                             players: [Player]?,
                             recordOrder: UInt8) -> ASEntity.Record?
    {
        guard let records, let players,
              !players.isEmpty,
              recordOrder > 0,
              let myId = mainRepository.myId,
              let myOrder = players.first(where: { $0.id == myId })?.order
        else { return nil }

        let targetOrder = findTargetOrder(for: myOrder, in: players.count)
        let targetId = players.first(where: { $0.order == targetOrder })?.id
        let hummings = findHummings(for: recordOrder, in: records)

        if let targetRecord = hummings.first(where: { $0.player?.id == targetId }) {
            return targetRecord
        } else {
            Logger.debug("\(targetId)에 대한 Record를 찾을 수 없음")
            return nil
        }
    }

    private func findTargetOrder(for myOrder: Int, in playersCount: Int) -> Int {
        return (myOrder - 1 + playersCount) % playersCount
    }

    private func findHummings(for recordOrder: UInt8, in records: [ASEntity.Record]) -> [ASEntity.Record] {
        return records.filter { $0.recordOrder == (recordOrder - 1) }
    }
}
