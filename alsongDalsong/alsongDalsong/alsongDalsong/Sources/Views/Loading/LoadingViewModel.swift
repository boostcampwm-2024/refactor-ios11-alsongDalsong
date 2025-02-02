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
    @Published var loadingStatus = ""
    
    func fetchAvatars() {
        Task {
            do {
                loadingStatus = String(localized: "게임 데이터 불러오는 중")
                avatars = try await avatarRepository.getAvatarUrls()

                guard let randomAvatarUrl = avatars.randomElement() else { return }
                selectedAvatar = randomAvatarUrl
                loadingStatus = String(localized: "아바타 이미지 다운로드 중")

                await withTaskGroup(of: Data?.self) { group in
                    avatars.forEach { url in
                        group.addTask { [weak self] in
                            return await self?.dataDownloadRepository.downloadData(url: url)
                        }
                    }
                }

                avatarData = await dataDownloadRepository.downloadData(url: randomAvatarUrl)
            } catch {
                let error = ASErrors(type: .fetchAvatars, reason: error.localizedDescription, file: #file, line: #line)
                LogHandler.handleError(error)
            }
        }
    }
}
