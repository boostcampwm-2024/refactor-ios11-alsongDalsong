@preconcurrency internal import FirebaseStorage
import Foundation

final class ASFirebaseStorage: ASFirebaseStorageProtocol {
    private let storageRef = Storage.storage().reference()
    
    func getAvatarUrls() async throws -> [URL] {
        let avatarRef = storageRef.child("avatar")
        do {
            let result = try await avatarRef.listAll()
            return try await fetchDownloadURLs(from: result.items)
        } catch {
            throw ASNetworkErrors(type: .getAvatarUrls, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
    
    private func fetchDownloadURLs(from items: [StorageReference]) async throws -> [URL] {
        try await withThrowingTaskGroup(of: URL.self) { taskGroup in
            items.forEach { item in
                taskGroup.addTask {
                    try await item.downloadURL()
                }
            }
            
            return try await taskGroup.reduce(into: []) { urls, url in
                urls.append(url)
            }
        }
    }
}
