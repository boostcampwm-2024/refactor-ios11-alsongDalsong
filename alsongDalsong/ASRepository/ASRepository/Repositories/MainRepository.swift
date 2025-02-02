import ASDecoder
import ASEntity
import ASLogKit
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

final class MainRepository: MainRepositoryProtocol {
    var myId: String? { ASFirebaseAuth.myID }
    var number = CurrentValueSubject<String?, Never>(nil)
    var host = CurrentValueSubject<Player?, Never>(nil)
    var players = CurrentValueSubject<[Player]?, Never>(nil)
    var mode = CurrentValueSubject<ASEntity.Mode?, Never>(nil)
    var round = CurrentValueSubject<UInt8?, Never>(nil)
    var status = CurrentValueSubject<ASEntity.Status?, Never>(nil)
    var recordOrder = CurrentValueSubject<UInt8?, Never>(nil)
    var answers = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    var dueTime = CurrentValueSubject<Date?, Never>(nil)
    var submits = CurrentValueSubject<[ASEntity.Answer]?, Never>(nil)
    var records = CurrentValueSubject<[ASEntity.Record]?, Never>(nil)
    var selectedRecords = CurrentValueSubject<[UInt8]?, Never>(nil)

    private let databaseManager: ASFirebaseDatabaseProtocol
    private let networkManager: ASNetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(databaseManager: ASFirebaseDatabaseProtocol, networkManager: ASNetworkManagerProtocol) {
        self.databaseManager = databaseManager
        self.networkManager = networkManager
    }

    func connectRoom(roomNumber: String) {
        databaseManager.addRoomListener(roomNumber: roomNumber)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        // TODO: - Error Handling
                        Logger.error(error.localizedDescription)
                    case .finished:
                        return
                }
            } receiveValue: { [weak self] room in
                guard let self else { return }
                update(\.number, with: room.number)
                update(\.host, with: room.host)
                update(\.players, with: room.players)
                update(\.mode, with: room.mode)
                update(\.round, with: room.round)
                update(\.status, with: room.status)
                update(\.recordOrder, with: room.recordOrder)
                update(\.answers, with: room.answers)
                update(\.dueTime, with: room.dueTime)
                update(\.submits, with: room.submits)
                update(\.records, with: room.records)
                update(\.selectedRecords, with: room.selectedRecords)
            }
            .store(in: &cancellables)
    }

    func disconnectRoom() {
        update(\.number, with: nil)
        update(\.host, with: nil)
        update(\.players, with: nil)
        update(\.mode, with: nil)
        update(\.round, with: nil)
        update(\.status, with: nil)
        update(\.recordOrder, with: nil)
        update(\.answers, with: nil)
        update(\.dueTime, with: nil)
        update(\.submits, with: nil)
        update(\.records, with: nil)
        update(\.selectedRecords, with: nil)
        databaseManager.removeRoomListener()
    }

    private func update<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<MainRepository, CurrentValueSubject<Value?, Never>>,
        with newValue: Value?
    ) {
        let subject = self[keyPath: keyPath]
        if subject.value != newValue {
            subject.send(newValue)
        }
    }

    func postRecording(_ record: Data) async throws -> Bool {
        do {
            let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                              URLQueryItem(name: "roomNumber", value: number.value)]
            let endPoint = FirebaseEndpoint(path: .uploadRecording, method: .post)
                .update(\.queryItems, with: queryItems)

            let response = try await networkManager.sendRequest(
                to: endPoint,
                type: .multipart,
                body: record,
                option: .none
            )
            let responseDict = try ASDecoder.decode([String: Bool].self, from: response)
            guard let success = responseDict["success"] else { return false }
            return success
        } catch {
            throw ASRepositoryErrors(type: .postRecording, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
    
    func postResetGame() async throws -> Bool {
        do {
            let queryItems = [URLQueryItem(name: "userId", value: ASFirebaseAuth.myID),
                              URLQueryItem(name: "roomNumber", value: number.value)]
            let endPoint = FirebaseEndpoint(path: .resetGame, method: .post)
                .update(\.queryItems, with: queryItems)

            let response = try await networkManager.sendRequest(
                to: endPoint,
                type: .none,
                body: nil,
                option: .none
            )

            let responseDict = try ASDecoder.decode([String: Bool].self, from: response)
            guard let success = responseDict["success"] else { return false }
            return success
        } catch {
            throw ASRepositoryErrors(type: .postResetGame, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
}
