import ASEntity
import ASRepositoryProtocol
import Combine

public final class RoomActionMockRepository: RoomActionRepositoryProtocol {
    public init() {}
    
    public func createRoom(nickname: String, avatar: URL) async throws -> String {
        "000000"
    }
    
    public func joinRoom(nickname: String, avatar: URL, roomNumber: String) async throws -> Bool {
        true
    }
    
    public func leaveRoom() async throws -> Bool {
        true
    }
    
    public func startGame(roomNumber: String) async throws -> Bool {
        true
    }
    
    public func changeMode(roomNumber: String, mode: ASEntity.Mode) async throws -> Bool {
        true
    }
    
    public func changeRecordOrder(roomNumber: String) async throws -> Bool {
        true
    }
    
    public func resetGame() async throws -> Bool {
        true
    }
}
