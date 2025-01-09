@preconcurrency internal import FirebaseStorage
import Foundation
import OSLog

public final class ASFirebaseStorage: ASFirebaseStorageProtocol {
    private let storageRef = Storage.storage().reference()
    
    public func getAvatarUrls() async throws -> [URL] {
        let avatarRef = storageRef.child("avatar")
        do {
            let result = try await avatarRef.listAll()
            os_log("\(#function): 아바타 리스트 가져옴")
            return try await fetchDownloadURLs(from: result.items)
        } catch {
            throw ASNetworkErrors.responseError
        }
    }
    
    private func fetchDownloadURLs(from items: [StorageReference]) async throws -> [URL] {
        try await withThrowingTaskGroup(of: URL.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    try await self.downloadURL(for: item)
                }
            }
            
            os_log("\(#function): 아바타 URL 다운로드")
            return try await taskGroup.reduce(into: []) { urls, url in
                urls.append(url)
            }
        }
    }

    private func downloadURL(for item: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            item.downloadURL { url, error in
                if let url = url {
                    continuation.resume(returning: url)
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
                
                os_log("\(#function): 아바타 개별 URL 메타데이터 다운로드")
            }
        }
    }
}
