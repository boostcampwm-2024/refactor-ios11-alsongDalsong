import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

final class AnswersRepository: AnswersRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    private var networkManager: ASNetworkManagerProtocol
    init(mainRepository: MainRepositoryProtocol, networkManager: ASNetworkManagerProtocol) {
        self.mainRepository = mainRepository
        self.networkManager = networkManager
    }

    func getAnswersCount() -> AnyPublisher<Int, Never> {
        mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    func getMyAnswer() -> AnyPublisher<Answer?, Never> {
        guard let myId = mainRepository.myId else {
            return Just(nil).eraseToAnyPublisher()
        }

        return mainRepository.answers
            .receive(on: DispatchQueue.main)
            .compactMap(\.self)
            .flatMap { answers in
                Just(answers.first { $0.player?.id == myId })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func submitMusic(answer: ASEntity.Music) async throws -> Bool {
        do {
            let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                              URLQueryItem(name: "roomNumber", value: mainRepository.number.value)]
            let endPoint = FirebaseEndpoint(path: .submitMusic, method: .post)
                .update(\.queryItems, with: queryItems)

            let body = try ASEncoder.encode(answer)
            let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
            let responseDict = try ASDecoder.decode([String: String].self, from: response)
            return !responseDict.isEmpty
        } catch {
            throw ASRepositoryErrors(type: .submitMusic, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
}
