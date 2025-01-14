import Foundation
import ASCacheKitProtocol

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
        let (currentSize, totalFiles) = calculateTotalCache()
        guard currentSize > maxSize else { return }
        
        let sortedFiles = totalFiles.sorted {
            let date1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let date2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return date1 < date2
        }
        
        var remainingSize = currentSize
        for fileURL in sortedFiles {
            guard remainingSize > maxSize else { break }
            
            let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            try? fileManager.removeItem(at: fileURL)
            remainingSize -= fileSize
        }
    }
    
    private func calculateTotalCache() -> (size: Int, files: [URL]) {
        guard let totalFiles = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { return (0, []) }
        
        let totalSize = totalFiles.reduce(0) { sum, fileURL in
            let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
            return sum + (fileSize ?? 0)
        }
        
        return (size: totalSize, files: totalFiles)
    }
}
