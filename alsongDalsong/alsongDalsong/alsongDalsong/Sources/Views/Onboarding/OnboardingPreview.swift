import ASContainer
import ASRepository
import ASRepositoryProtocol
import SwiftUI
import UIKit

struct OnboardingPreview: PreviewProvider {
    static var previews: some View {
        let roomActionRepository = RoomActionMockRepository()
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        let saveDataRepository = DIContainer.shared.resolve(SaveDataRepositoryProtocol.self)
        
        let onboardingViewModel = OnboardingViewModel(
            roomActionRepository: roomActionRepository,
            dataDownloadRepository: dataDownloadRepository,
            saveDataRepository: saveDataRepository,
            avatars: [],
            selectedAvatar: nil,
            avatarData: nil
        )
        return OnboardingViewController(
            viewModel: onboardingViewModel,
            inviteCode: ""
        ).toPreview()
    }
}
