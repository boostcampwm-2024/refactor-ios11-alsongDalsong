import Foundation
import ASCacheKitProtocol

final class MemoryCacheManager: @unchecked Sendable, MemoryCacheManagerProtocol {
    private let cache = NSCache<NSString, AnyObject>()
    
    init() {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let percentage = 10
        cache.totalCostLimit = Int(totalMemory) * percentage / 100
    }

    func getObject(forKey key: String) -> AnyObject? {
        return cache.object(forKey: key.sha256 as NSString)
    }

    func setObject(_ object: AnyObject, forKey key: String) {
        cache.setObject(object, forKey: key.sha256 as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

