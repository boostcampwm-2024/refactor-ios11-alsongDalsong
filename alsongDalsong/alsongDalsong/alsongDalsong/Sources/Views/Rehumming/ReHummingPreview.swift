import ASContainer
import ASRepository
import ASRepositoryProtocol
import SwiftUI
import UIKit

#if DEBUG
struct ReHummingPreview: PreviewProvider {
    static var previews: some View {
        let gameStatusRepository = GameStatusMockRepository(status: .humming)
        let playerRepository = PlayersMockRepository()
        let recordsRepository = RecordsMockRepository()
        let rehummingViewModel = RehummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playerRepository,
            recordsRepository: recordsRepository
        )
        return RehummingViewController(viewModel: rehummingViewModel).toPreview()
    }
}
#endif
