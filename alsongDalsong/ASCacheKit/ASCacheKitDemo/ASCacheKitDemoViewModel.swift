import ASCacheKit
import ASCacheKitProtocol
import Foundation

final class ASCacheKitDemoViewModel: ObservableObject {
    private var cacheManager = MockCacheManager()
    @Published var imageData: Data?

    @MainActor
    func loadCacheData(at cacheOption: CacheOption) {
        guard let url = URL(string: "https://picsum.photos/id/13/600/600") else { return }
        
        Task {
            imageData = cacheManager.loadCache(from: url, cacheOption: cacheOption)
        }
    }

    func clearCache(at cacheOption: CacheOption) {
        switch cacheOption {
            case .onlyMemory:
                cacheManager.memoryCache.clearCache()
            case .onlyDisk:
                cacheManager.diskCache.clearCache()
            case .both:
                cacheManager.memoryCache.clearCache()
                cacheManager.diskCache.clearCache()
            default: break
        }
    }
}
