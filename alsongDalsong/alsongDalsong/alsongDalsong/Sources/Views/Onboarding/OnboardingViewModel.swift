import ASMusicKit
import ASRepositoryProtocol
import Foundation

final class OnboardingViewModel: @unchecked Sendable {
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var dataDownloadRepository: DataDownloadRepositoryProtocol
    private var avatars: [URL] = []
    private var selectedAvatar: URL?

    @Published var nickname: String = NickNameGenerator.generate()
    @Published var avatarData: Data?
    @Published var buttonEnabled: Bool = true

    init(roomActionRepository: RoomActionRepositoryProtocol,
         dataDownloadRepository: DataDownloadRepositoryProtocol,
         avatars: [URL],
         selectedAvatar: URL?,
         avatarData: Data?
    ) {
        self.roomActionRepository = roomActionRepository
        self.dataDownloadRepository = dataDownloadRepository
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
    }

    func setNickname(with nickname: String) {
        self.nickname = nickname
    }

    func refreshAvatars() {
        Task {
            let filteredAvatars = avatars.filter { $0 != selectedAvatar }
            guard let randomAvatarUrl = filteredAvatars.randomElement() else { return }
            selectedAvatar = randomAvatarUrl
            avatarData = await dataDownloadRepository.downloadData(url: randomAvatarUrl)
        }
    }

    @MainActor
    func authorizeAppleMusic() {
        let musicAPI = ASMusicAPI()
        Task {
            do {
                let _ = try await musicAPI.search(for: "뉴진스", 1, 1)
            } catch {
                LogHandler.handleError(.authorizeAppleMusicError(reason: error.localizedDescription))
            }
        }
    }

    @MainActor
    func joinRoom(roomNumber id: String) async throws -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            buttonEnabled = try await roomActionRepository.joinRoom(nickname: nickname, avatar: selectedAvatar, roomNumber: id)
            return id
        } catch {
            buttonEnabled = true
            LogHandler.handleError(.joinRoomError(reason: error.localizedDescription))
            throw ASErrors.joinRoomError(reason: error.localizedDescription)
        }
    }

    @MainActor
    func createRoom() async throws -> String? {
        guard let selectedAvatar else { return nil }
        buttonEnabled = false
        do {
            let roomNumber = try await roomActionRepository.createRoom(nickname: nickname, avatar: selectedAvatar)
            return try await joinRoom(roomNumber: roomNumber)
        } catch {
            buttonEnabled = true
            LogHandler.handleError(.createRoomError(reason: error.localizedDescription))
            throw ASErrors.createRoomError(reason: error.localizedDescription)
        }
    }
}
