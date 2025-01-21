import ASNetworkKit
import Combine
import Foundation
import ASRepositoryProtocol

final class AvatarRepository: AvatarRepositoryProtocol {
    // TODO: - Container로 주입
    private let storageManager: ASFirebaseStorageProtocol
    
    init (
        storageManager: ASFirebaseStorageProtocol
    ) {
        self.storageManager = storageManager
    }
    
    func getAvatarUrls() async throws -> [URL] {
        do {
            let urls = try await self.storageManager.getAvatarUrls()
            return urls
        } catch {
            throw ASRepositoryErrors.getAvatarUrlsError(reason: error.localizedDescription)
        }
    }
}
