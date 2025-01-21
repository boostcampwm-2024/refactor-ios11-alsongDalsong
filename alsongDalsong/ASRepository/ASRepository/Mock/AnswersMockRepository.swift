import ASEntity
import ASNetworkKit
import ASRepositoryProtocol
import Combine

public final class AnswersMockRepository: AnswersRepositoryProtocol {
    // MARK: 3개의 더미 데이터로 대체

    private let answersStub = [Answer.answerStub2, Answer.answerStub3, Answer.answerStub4]
    private let answersPublisher: CurrentValueSubject<[Answer], Never> = .init([])

    public init() {
        answersPublisher.send(answersStub)
    }

    public func getAnswersCount() -> AnyPublisher<Int, Never> {
        answersPublisher
            .map(\.count)
            .eraseToAnyPublisher()
    }

    public func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        answersPublisher
            .map { answers in
                answers.first { $0.player?.id == Player.playerStub1.id }
            }
            .eraseToAnyPublisher()
    }

    public func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        answersPublisher.send(answersStub + [Answer.answerStub4])
        return true
    }
}
