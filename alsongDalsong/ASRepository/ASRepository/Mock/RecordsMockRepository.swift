import ASEntity
import ASRepositoryProtocol
import Combine

public final class RecordsMockRepository: RecordsRepositoryProtocol {
    private let recordsStub = [Record.recordStub1_1, Record.recordStub1_2, Record.recordStub1_3]
    private let recordsPublisher: CurrentValueSubject<[ASEntity.Record], Never> = .init([])

    public init() {
        recordsPublisher.send(recordsStub)
    }

    public func getRecordsCount(on recordOrder: UInt8) -> AnyPublisher<Int, Never> {
        recordsPublisher
            .receive(on: DispatchQueue.main)
            .map(\.count)
            .eraseToAnyPublisher()
    }

    public func getHumming(on recordOrder: UInt8) -> AnyPublisher<ASEntity.Record?, Never> {
        Just(recordsStub.first)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func uploadRecording(_ record: Data) async throws -> Bool {
        true
    }
}
