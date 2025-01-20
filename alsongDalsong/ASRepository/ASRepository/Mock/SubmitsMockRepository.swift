import ASEntity
import ASRepositoryProtocol
import Combine

public final class SubmitsMockRepository: SubmitsRepositoryProtocol {
    public init() {}

    public func getSubmitsCount() -> AnyPublisher<Int, Never> {
        Just(3)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func submitAnswer(answer: Music) async throws -> Bool {
        true
    }
}
