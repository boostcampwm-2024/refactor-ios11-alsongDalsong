import ASContainer
import ASRepository
import ASRepositoryProtocol
import SwiftUI
import UIKit

struct LobbyPreview: PreviewProvider {
    static var previews: some View {
        let playerRepository = PlayersMockRepository()
        let roomInfoRepository = RoomInfoMockRepository()
        let roomActionRepository = RoomActionMockRepository()
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)

        let lobbyViewModel = LobbyViewModel(
            playersRepository: playerRepository,
            roomInfoRepository: roomInfoRepository,
            roomActionRepository: roomActionRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        return LobbyViewController(lobbyViewModel: lobbyViewModel).toPreview()
    }
}
