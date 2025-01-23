import ASContainer
import ASRepository
import ASRepositoryProtocol
import SwiftUI
import UIKit

struct HummingResultPreview: PreviewProvider {
    static var previews: some View {
        let hummingResultRepository = HummingResultMockRepository()
        let gameStatusRepository = GameStatusMockRepository(status: .result)
        let playerRepository = PlayersMockRepository()
        let roomActionRepository = RoomActionMockRepository()
        let roomInfoRepository = RoomInfoMockRepository()
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        let hummingResultViewModel = HummingResultViewModel(
            hummingResultRepository: hummingResultRepository,
            gameStatusRepository: gameStatusRepository,
            playerRepository: playerRepository,
            roomActionRepository: roomActionRepository,
            roomInfoRepository: roomInfoRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        return HummingResultViewController(viewModel: hummingResultViewModel).toPreview()
    }
}
