import ASContainer
import ASRepository
import ASRepositoryProtocol
import SwiftUI
import UIKit

struct HummingPreview: PreviewProvider {
    @UIApplicationDelegateAdaptor(AppDelegate.self) static var appDelegate
    static var previews: some View {
        let gameStatusRepository = GameStatusMockRepository(status: .humming)
        let playerRepository = PlayersMockRepository()
        let answersRepository = AnswersMockRepository()
        let recordsRepository = RecordsMockRepository()
        let hummingViewModel = HummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playerRepository,
            answersRepository: answersRepository,
            recordsRepository: recordsRepository
        )
        return HummingViewController(viewModel: hummingViewModel).toPreview()
    }
}
