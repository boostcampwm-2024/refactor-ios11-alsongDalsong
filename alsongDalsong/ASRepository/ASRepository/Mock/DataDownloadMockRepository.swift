import ASNetworkKit
import ASRepositoryProtocol

public final class DataDownloadMockRepository: DataDownloadRepositoryProtocol {
    private var networkManager: ASNetworkManagerProtocol

    public init(networkManager: ASNetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    public func downloadData(url: URL) async -> Data? {
        guard let endpoint = ResourceEndpoint(url: url) else { return nil }
        do {
            let data = try await networkManager.sendRequest(to: endpoint, type: .none, body: nil, option: .none)
            return data
        } catch {
            return nil
        }
    }
}
