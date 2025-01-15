import ASNetworkKit
import ASRepositoryProtocol

final class DataDownloadRepository: DataDownloadRepositoryProtocol {
    private var networkManager: ASNetworkManagerProtocol

    init(networkManager: ASNetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func downloadData(url: URL) async -> Data? {
        guard let endpoint = ResourceEndpoint(url: url) else { return nil }
        do {
            let data = try await networkManager.sendRequest(to: endpoint, type: .none, body: nil, option: .both)
            return data
        } catch {
            return nil
        }
    }
}
