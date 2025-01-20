import ASEntity
import ASRepositoryProtocol
import Combine

public final class GameStatusMockRepository: GameStatusRepositoryProtocol {
    private let statusPublisher = CurrentValueSubject<Status?, Never>(nil)
    private let recordOrderPublisher = CurrentValueSubject<UInt8?, Never>(nil)
    private let dueTimePublisher = CurrentValueSubject<Date?, Never>(nil)
    
    public init(status: Status) {
        statusPublisher.send(status)
        dueTimePublisher.send(Date().addingTimeInterval(60))
        switch status {
        case .humming:
            recordOrderPublisher.send(0)
        case .rehumming:
            recordOrderPublisher.send(1)
        case .result:
            recordOrderPublisher.send(2)
        default:
            break
        }
    }
    
    public func getStatus() -> AnyPublisher<Status?, Never> {
        statusPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func getRecordOrder() -> AnyPublisher<UInt8, Never> {
        recordOrderPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func getDueTime() -> AnyPublisher<Date, Never> {
        dueTimePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
