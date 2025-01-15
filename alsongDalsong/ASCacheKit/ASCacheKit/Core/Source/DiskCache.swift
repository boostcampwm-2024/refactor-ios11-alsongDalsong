import Foundation
import ASCacheKitProtocol
import ASLogKit

final class DiskCacheManager: @unchecked Sendable, DiskCacheManagerProtocol {
    private let fileManager = FileManager.default
    let cacheDirectory: URL
    let maxSize = 350 * 1024 * 1024 // 350MB
    
    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("MediaDiskCache")
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func getData(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.sha256)
        try? fileManager.setAttributes([.modificationDate : Date.now], ofItemAtPath: fileURL.path)
        return try? Data(contentsOf: fileURL)
    }
    
    func saveData(_ data: Data, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.sha256)
        try? data.write(to: fileURL)
        optimizeCache()
    }
    
    func clearCache() {
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for fileURL in files {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    /// 캐시를 최적화하는 메서드
    /// comment
    ///
    /// 설정해둔 max 용량보다 크면 가장 사용한지 오래된 캐시를 지웁니다.
    private func optimizeCache() {
        let (totalSize, cachedFilesMetaData) = getCachedFileMetaData()
        guard totalSize > maxSize else { return }
        
        let sortedFiles = cachedFilesMetaData.sorted { $0.lastModifiedDate < $1.lastModifiedDate }
        
        var remainingSize = totalSize
        for metaData in sortedFiles {
            guard remainingSize > maxSize else { break }
            
            do {
                try fileManager.removeItem(at: metaData.url)
                remainingSize -= metaData.size
            } catch {
                Logger.debug("캐시 삭제 실패")
            }
        }
    }
    
    private func getCachedFileMetaData() -> (totalSize: Int, metaData: [CachedFile]) {
        guard let totalFiles = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { return (0, []) }
        
        var totalSize = 0
        var cachedFilesMetaData = [CachedFile]()
        
        for fileURL in totalFiles {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let fileSize = resourceValues?.fileSize ?? 0
            let modificationDate = resourceValues?.contentModificationDate ?? Date.distantPast
            
            totalSize += fileSize
            cachedFilesMetaData.append(CachedFile(url: fileURL, size: fileSize, lastModifiedDate: modificationDate))
        }
        
        return (totalSize, cachedFilesMetaData)
    }
}
