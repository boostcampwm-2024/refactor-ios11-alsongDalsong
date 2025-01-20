import ASCacheKitProtocol

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
