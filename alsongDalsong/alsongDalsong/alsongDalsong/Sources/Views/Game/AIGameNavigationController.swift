import ASContainer
import ASEntity
import ASRepositoryProtocol
import UIKit

@MainActor
final class AIGameNavigationController: GameNavigationController, @unchecked Sendable {
    private var aiImageURL: [URL?]
    private var tutorialStep: TutorialState? {
        didSet {
            updateViewControllers()
        }
    }

    init(navigationController: UINavigationController, aiImageURL: [URL?]) {
        self.aiImageURL = aiImageURL
        super.init(with: navigationController)
    }
    
    override func setConfiguration() {
        tutorialStep = .start
    }
    
    override func navigateToLobby() {
        super.navigateToLobby()
        
        let dataDownloadRepository: DataDownloadRepositoryProtocol = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        let playersRepository: PlayersRepositoryProtocol = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        
        let vm: LobbyViewModel = AILobbyViewModel(
            dataDownloadRepository: dataDownloadRepository,
            playersRepository: playersRepository,
            aiImageURL: aiImageURL.compactMap { $0 }
        )
        let vc = LobbyViewController(lobbyViewModel: vm)
        setupNavigationBar(for: vc)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func updateViewControllers() {
        switch tutorialStep {
            case .start:
                navigateToLobby()
            default:
                break
        }
    }
    
    override func setupNavigationBar(for viewController: UIViewController) {
        super.setupNavigationBar(for: viewController)
        
        viewController.navigationItem.hidesBackButton = true
        viewController.title = setTitle()

    }
}

private extension AIGameNavigationController {
    func setTitle() -> String {
        switch tutorialStep {
        case .start:
            return String(localized: "튜토리얼")
        default: return ""
        }
    }
}
