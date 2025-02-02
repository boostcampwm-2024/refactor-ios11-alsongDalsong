import ASDecoder
import ASEncoder
import ASEntity
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

final class SubmitsRepository: SubmitsRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol
    private var networkManager: ASNetworkManagerProtocol

    init(mainRepository: MainRepositoryProtocol, networkManager: ASNetworkManagerProtocol) {
        self.mainRepository = mainRepository
        self.networkManager = networkManager
    }
    
    func getSubmitsCount() -> AnyPublisher<Int, Never> {
        mainRepository.submits
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    func submitAnswer(answer: Music) async throws -> Bool {
        do {
            let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                              URLQueryItem(name: "roomNumber", value: mainRepository.number.value)]
            let endPoint = FirebaseEndpoint(path: .submitAnswer, method: .post)
                .update(\.queryItems, with: queryItems)
                .update(\.headers, with: ["Content-Type": "application/json"])

            let body = try ASEncoder.encode(answer)
            let response = try await networkManager.sendRequest(to: endPoint, type: .json, body: body, option: .none)
            let responseDict = try ASDecoder.decode([String: String].self, from: response)
            return !responseDict.isEmpty
        } catch {
            throw ASRepositoryErrors(type: .submitAnswer, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
}
