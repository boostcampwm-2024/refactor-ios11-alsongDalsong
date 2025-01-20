import ASEntity
import ASRepositoryProtocol
import Combine

public final class RoomInfoMockRepository: RoomInfoRepositoryProtocol {
    public init() {}

    public func getRoomNumber() -> AnyPublisher<String, Never> {
        Just("000000")
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func getMode() -> AnyPublisher<Mode, Never> {
        Just(.humming)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
