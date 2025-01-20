@testable import ASCacheKit
import ASCacheKitProtocol
import Testing
import UIKit

struct ASCacheKitTests {
    private let cacheManager: ASCacheManager
    private let testData: Data
    private let testImageURL: URL
    
    init() throws {
        cacheManager = ASCacheManager()
        testData = try #require(UIImage(systemName: "star")?.pngData())
        testImageURL = try #require(URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUcmUojj8oZ0EzJU027Pul8SpM6ZMxr8HXAgsuunxkFZKSW7K27kLqcsoRaWaEX03kmQg&usqp=CAU"))
    }

    @Test("디스크에 없는 캐시 로딩") func loadNonExistingCacheFromDisk() async throws {
        let diskData = cacheManager.diskCache.getData(forKey: "url")

        #expect(diskData == nil)
    }

    @Test("디스크에 있는 캐시 로딩") func loadExistingCacheFromDisk() async throws {
        cacheManager.saveCache(withKey: testImageURL, data: testData, cacheOption: .onlyDisk)
        let cachedData = cacheManager.loadCache(from: testImageURL, cacheOption: .onlyDisk)
        let diskData = cacheManager.diskCache.getData(forKey: testImageURL.absoluteString)

        #expect(cachedData != nil)
        #expect(diskData != nil)
    }

    @Test("메모리에 없는 캐시 로딩") func loadNonExistingCacheFromMemory() async throws {
        let memoryData = cacheManager.memoryCache.getObject(forKey: "url")

        #expect(memoryData == nil)
    }

    @Test("메모리에 있는 캐시 로딩") func loadExistingCacheFromMemory() async throws {
        cacheManager.saveCache(withKey: testImageURL, data: testData, cacheOption: .onlyMemory)
        let cachedData = cacheManager.loadCache(from: testImageURL, cacheOption: .onlyMemory)
        let memoryData = cacheManager.memoryCache.getObject(forKey: testImageURL.absoluteString)

        #expect(cachedData != nil)
        #expect(memoryData != nil)
    }
}
