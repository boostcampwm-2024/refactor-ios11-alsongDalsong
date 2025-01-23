import ASCacheKitProtocol
import Foundation

final class MockCacheManager: CacheManagerProtocol {
    let diskCache = MockDiskCacheManager()
    let memoryCache = MockMemoryCacheManager()
    
    func loadCache(from url: URL, cacheOption: CacheOption) -> Data? {
        let cacheKey = url.absoluteString
        return loadData(forKey: cacheKey, cacheOption: cacheOption)
    }

    func saveCache(withKey url: URL, data: Data, cacheOption: CacheOption) {
        let cacheKey = url.absoluteString
        switch cacheOption {
            case .onlyMemory:
                memoryCache.setObject(data as NSData, forKey: cacheKey)
            case .onlyDisk:
                diskCache.saveData(data, forKey: cacheKey)
            case .both:
                memoryCache.setObject(data as NSData, forKey: cacheKey)
                diskCache.saveData(data, forKey: cacheKey)
            default: break
        }
    }

    private func loadData(forKey key: String, cacheOption: CacheOption) -> Data? {
        switch cacheOption {
            case .onlyMemory:
                return loadFromMemory(forKey: key)
            case .onlyDisk:
                return loadFromDisk(forKey: key)
            case .both:
                if let cachedData = loadFromMemory(forKey: key) {
                    return cachedData
                }
                if let diskData = loadFromDisk(forKey: key) {
                    return diskData
                }
                return nil
            default:
                return nil
        }
    }

    private func loadFromMemory(forKey key: String) -> Data? {
        return memoryCache.getObject(forKey: key) as? Data
    }

    private func loadFromDisk(forKey key: String) -> Data? {
        if let diskData = diskCache.getData(forKey: key) {
            memoryCache.setObject(diskData as NSData, forKey: key)
            return diskData
        }
        return nil
    }
}

final class MockDiskCacheManager: @unchecked Sendable, DiskCacheManagerProtocol {
    private var mockStorage: [String: Data] = [:]

    func getData(forKey key: String) -> Data? {
        return mockStorage[key]
    }

    func saveData(_ data: Data, forKey key: String) {
        mockStorage[key] = data
    }

    func clearCache() {
        mockStorage.removeAll()
    }
}

final class MockMemoryCacheManager: @unchecked Sendable, MemoryCacheManagerProtocol {
    private var mockStorage: [String: AnyObject] = [:]

    func getObject(forKey key: String) -> AnyObject? {
        return mockStorage[key]
    }

    func setObject(_ object: AnyObject, forKey key: String) {
        mockStorage[key] = object
    }

    func clearCache() {
        mockStorage.removeAll()
    }
}
