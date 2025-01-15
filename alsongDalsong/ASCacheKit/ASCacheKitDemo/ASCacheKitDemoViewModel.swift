import ASCacheKit
import ASCacheKitProtocol
import Foundation

class ASCacheKitDemoViewModel: ObservableObject {
    private var cacheManager = ASCacheManager()
    private let imageURL = URL(string: "https://picsum.photos/id/13/600/600")!
    @Published var imageData: Data?

    @MainActor
    func loadCacheData(at cacheOption: CacheOption) {
        Task {
            imageData = await cacheManager.loadCache(from: imageURL, cacheOption: cacheOption)
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
