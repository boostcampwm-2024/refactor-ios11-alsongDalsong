import ASEntity
import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

final class RoomActionRepository: RoomActionRepositoryProtocol {
    private let mainRepository: MainRepositoryProtocol
    private let authManager: ASFirebaseAuthProtocol
    private let networkManager: ASNetworkManagerProtocol
    
    init(
        mainRepository: MainRepositoryProtocol,
        authManager: ASFirebaseAuthProtocol,
        networkManager: ASNetworkManagerProtocol
    ) {
        self.mainRepository = mainRepository
        self.authManager = authManager
        self.networkManager = networkManager
    }

    func createRoom(nickname: String, avatar: URL) async throws -> String {
        do {
            try await self.authManager.signIn(nickname: nickname, avatarURL: avatar)
            let response: [String: String]? = try await self.sendRequest(
                endpointPath: .createRoom,
                requestBody: ["hostID": ASFirebaseAuth.myID]
            )
            guard let roomNumber = response?["number"] as? String else {
                throw ASNetworkErrors.responseError
            }
            return roomNumber
        } catch {
            throw ASRepositoryErrors.createRoomError(reason: error.localizedDescription)
        }
    }
    
    func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool {
        do {
            let player = try await self.authManager.signIn(nickname: nickname, avatarURL: avatar)
            let response: [String: String]? = try await self.sendRequest(
                endpointPath: .joinRoom,
                requestBody: ["roomNumber": roomNumber, "userId": ASFirebaseAuth.myID]
            )
            guard let roomNumberResponse = response?["number"] as? String else {
                throw ASNetworkErrors.responseError
            }
            return roomNumberResponse == roomNumber
        } catch {
            throw ASRepositoryErrors.joinRoomError(reason: error.localizedDescription)
        }
    }
    
    func leaveRoom() async throws -> Bool {
        do {
            self.mainRepository.disconnectRoom()
            try await self.authManager.signOut()
            return true
        } catch {
            throw ASRepositoryErrors.leaveRoomError(reason: error.localizedDescription)
        }
    }
    
    func startGame(roomNumber: String) async throws -> Bool {
        do {
            let response: [String: Bool]? = try await self.sendRequest(
                endpointPath: .gameStart,
                requestBody: ["roomNumber": roomNumber, "userId": ASFirebaseAuth.myID]
            )
            guard let response = response?["success"] as? Bool else {
                throw ASNetworkErrors.responseError
            }
            return response
        } catch {
            throw ASRepositoryErrors.startGameError(reason: error.localizedDescription)
        }
    }
    
    func changeMode(roomNumber: String, mode: Mode) async throws -> Bool {
        do {
            let response: [String: Bool] = try await self.sendRequest(
                endpointPath: .changeMode,
                requestBody: ["roomNumber": roomNumber, "userId": ASFirebaseAuth.myID, "mode": mode.rawValue]
            )
            guard let isSuccess = response["success"] as? Bool else {
                throw ASNetworkErrors.responseError
            }
            return isSuccess
        } catch {
            throw ASRepositoryErrors.changeModeError(reason: error.localizedDescription)
        }
    }
    
    func changeRecordOrder(roomNumber: String) async throws -> Bool {
        do {
            let response: [String: Bool] = try await self.sendRequest(
                endpointPath: .changeRecordOrder,
                requestBody: ["roomNumber": roomNumber, "userId": ASFirebaseAuth.myID]
            )
            guard let isSuccess = response["success"] as? Bool else {
                throw ASNetworkErrors.responseError
            }
            return isSuccess
        } catch {
            throw ASRepositoryErrors.changeRecordOrderError(reason: error.localizedDescription)
        }
    }
    
    func resetGame() async throws -> Bool {
        do {
            return try await mainRepository.postResetGame()
        } catch {
            throw ASRepositoryErrors.resetGameError(reason: error.localizedDescription)
        }
    }
    
    private func sendRequest<T: Decodable>(endpointPath: FirebaseEndpoint.Path, requestBody: [String: Any]) async throws -> T {
        do {
            let endpoint = FirebaseEndpoint(path: endpointPath, method: .post)
            let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            let data = try await networkManager.sendRequest(to: endpoint, type: .json, body: body, option: .none)
            let response = try JSONDecoder().decode(T.self, from: data)
            return response
        } catch {
            throw ASRepositoryErrors.sendRequestError(reason: error.localizedDescription)
        }
    }
}
