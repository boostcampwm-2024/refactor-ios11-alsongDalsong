import ASRepositoryProtocol
import Foundation

final class LoadingViewModel: @unchecked Sendable {
    private var avatarRepository: AvatarRepositoryProtocol
    private var dataDownloadRepository: DataDownloadRepositoryProtocol
    private(set) var avatars: [URL] = []
    private(set) var selectedAvatar: URL?

    init(
        avatarRepository: AvatarRepositoryProtocol,
        dataDownloadRepository: DataDownloadRepositoryProtocol
    ) {
        self.avatarRepository = avatarRepository
        self.dataDownloadRepository = dataDownloadRepository
        fetchAvatars()
    }
    
    @Published var avatarData: Data?
    
    func fetchAvatars() {
        Task {
            if avatars.isEmpty {
                avatars = try await avatarRepository.getAvatarUrls()
            }
            
            guard let randomAvatarUrl = avatars.randomElement() else { return }
            selectedAvatar = randomAvatarUrl
            avatarData = await dataDownloadRepository.downloadData(url: randomAvatarUrl)
        }
    }
}
