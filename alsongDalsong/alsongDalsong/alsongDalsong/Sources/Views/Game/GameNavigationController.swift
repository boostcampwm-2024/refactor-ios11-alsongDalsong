import ASContainer
import ASEntity
import ASRepositoryProtocol
import Combine
import UIKit

@MainActor
final class GameNavigationController: @unchecked Sendable {
    private let navigationController: UINavigationController
    private let gameStateRepository: GameStateRepositoryProtocol
    private let roomActionRepository: RoomActionRepositoryProtocol
    private var subscriptions: Set<AnyCancellable> = []

    private var gameInfo: GameState? {
        didSet {
            guard let gameInfo else { return }
            updateViewControllers(state: gameInfo)
        }
    }

    private let roomNumber: String

    init(navigationController: UINavigationController,
         gameStateRepository: GameStateRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         roomNumber: String)
    {
        self.navigationController = navigationController
        self.gameStateRepository = gameStateRepository
        self.roomActionRepository = roomActionRepository
        self.roomNumber = roomNumber
    }

    func setConfiguration() {
        gameStateRepository.getGameState()
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] gameState in
                self?.gameInfo = gameState
            }
            .store(in: &subscriptions)
    }

    private func setupNavigationBar(for viewController: UIViewController) {
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.tintColor = .asBlack
        let defaultFontSize = UIFont.preferredFont(forTextStyle: .headline).pointSize as CGFloat?
        var fontStyle = UIFont()
        if let defaultFontSize {
            fontStyle = .font(setFont(), ofSize: defaultFontSize)
        } else {
            fontStyle = .font(setFont(), ofSize: 18)
        }
        navigationController.navigationBar.titleTextAttributes = [.font: fontStyle]
        let backButtonImage = setImage()

        let backButtonAction = UIAction { [weak self] _ in
            let alert = DefaultAlertController(
                titleText: .leaveRoom,
                primaryButtonText: .leave,
                secondaryButtonText: .cancel
            ) { [weak self] _ in
                self?.leaveRoom()
                self?.navigationController.popToRootViewController(animated: true)
                self?.navigationController.navigationBar.isHidden = true
            }
            self?.navigationController.presentAlert(alert)
        }

        let backButton = UIBarButtonItem(image: backButtonImage, primaryAction: backButtonAction)

        viewController.navigationItem.leftBarButtonItem = backButton
        viewController.title = setTitle()
    }

    private func setTitle() -> String {
        guard let gameInfo else { return "" }
        let viewType = gameInfo.resolveViewType()
        switch viewType {
            case .submitMusic:
                return String(localized: "노래 선택")
            case .humming:
                return String(localized: "허밍")
            case .rehumming:
                guard let recordOrder = gameInfo.recordOrder else { return "" }
                let rounds = gameInfo.players.count - 2
                return String(localized: "리허밍") + "\(recordOrder)/\(rounds)"
            case .submitAnswer:
                return String(localized: "정답 맞추기")
            case .result:
                guard let recordOrder = gameInfo.recordOrder else { return "" }
                let currentRound = Int(recordOrder) - (gameInfo.players.count - 2)
                return String(localized: "결과 확인") + " \(currentRound)/\(gameInfo.players.count)"
            case .lobby:
                return "#\(roomNumber)"
            default:
                return ""
        }
    }
    
    private func setFont() -> FontName {
        let viewType = gameInfo?.resolveViewType()
        if case .lobby = viewType {
            return .neoDunggeunmoPro
        } else {
            return .dohyeon
        }
    }

    private func setImage() -> UIImage? {
        guard let gameInfo else { return UIImage() }
        let viewType = gameInfo.resolveViewType()
        switch viewType {
            case .lobby: return UIImage(systemName: "rectangle.portrait.and.arrow.forward")?
            .rotate(radians: .pi)
            default: return UIImage(systemName: "house")
        }
    }

    private func updateViewControllers(state: GameState) {
        let viewType = state.resolveViewType()
        switch viewType {
            case .submitMusic:
                navigateToSelectMusic()
            case .humming:
                navigateToHumming()
            case .rehumming:
                navigateToRehumming()
            case .submitAnswer:
                navigateToSubmitAnswer()
            case .result:
                navigateToResult()
            case .lobby:
                navigateToLobby()
            default:
                break
        }
    }

    private func navigateToLobby() {
        if navigationController.topViewController is LobbyViewController {
            return
        }

        if let vc = navigationController.viewControllers.first(where: { $0 is LobbyViewController }) {
            navigationController.popToViewController(vc, animated: true)
            return
        }

        let roomInfoRepository: RoomInfoRepositoryProtocol = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
        let playersRepository: PlayersRepositoryProtocol = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let roomActionRepository: RoomActionRepositoryProtocol = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let dataDownloadRepository: DataDownloadRepositoryProtocol = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)

        let vm = LobbyViewModel(
            playersRepository: playersRepository,
            roomInfoRepository: roomInfoRepository,
            roomActionRepository: roomActionRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        let vc = LobbyViewController(lobbyViewModel: vm)
        setupNavigationBar(for: vc)
        navigationController.pushViewController(vc, animated: true)
    }

    private func navigateToSelectMusic() {
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)

        let vm = SelectMusicViewModel(
            playersRepository: playersRepository,
            answerRepository: answersRepository,
            gameStatusRepository: gameStatusRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        let vc = SelectMusicViewController(selectMusicViewModel: vm)

        let guideVC = GuideViewController(type: .submitMusic) { [weak self] in
            guard let self else { return }
            navigationController.pushViewController(vc, animated: true)
            setupNavigationBar(for: vc)
        }
        navigationController.pushViewController(guideVC, animated: true)
    }

    private func navigateToHumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let answersRepository = DIContainer.shared.resolve(AnswersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)

        let vm = HummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            answersRepository: answersRepository,
            recordsRepository: recordsRepository
        )
        let vc = HummingViewController(viewModel: vm)

        let guideVC = GuideViewController(type: .humming) { [weak self] in
            guard let self else { return }
            navigationController.pushViewController(vc, animated: true)
            setupNavigationBar(for: vc)
        }
        navigationController.pushViewController(guideVC, animated: true)
    }

    private func navigateToRehumming() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)

        let vm = RehummingViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            recordsRepository: recordsRepository
        )
        let vc = RehummingViewController(viewModel: vm)

        let guideVC = GuideViewController(type: .rehumming) { [weak self] in
            guard let self else { return }
            navigationController.pushViewController(vc, animated: true)
            setupNavigationBar(for: vc)
        }
        navigationController.pushViewController(guideVC, animated: true)
    }

    private func navigateToSubmitAnswer() {
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playersRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let recordsRepository = DIContainer.shared.resolve(RecordsRepositoryProtocol.self)
        let submitsRepository = DIContainer.shared.resolve(SubmitsRepositoryProtocol.self)
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        
        let vm = SubmitAnswerViewModel(
            gameStatusRepository: gameStatusRepository,
            playersRepository: playersRepository,
            recordsRepository: recordsRepository,
            submitsRepository: submitsRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        let vc = SubmitAnswerViewController(viewModel: vm)

        let guideVC = GuideViewController(type: .submitAnswer) { [weak self] in
            guard let self else { return }
            navigationController.pushViewController(vc, animated: true)
            setupNavigationBar(for: vc)
        }
        navigationController.pushViewController(guideVC, animated: true)
    }

    private func navigateToResult() {
        if navigationController.topViewController is HummingResultViewController {
            navigationController.topViewController?.title = setTitle()
            return
        }
        let hummingResultRepository = DIContainer.shared.resolve(HummingResultRepositoryProtocol.self)
        let gameStatusRepository = DIContainer.shared.resolve(GameStatusRepositoryProtocol.self)
        let playerRepository = DIContainer.shared.resolve(PlayersRepositoryProtocol.self)
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let roomInfoRepository = DIContainer.shared.resolve(RoomInfoRepositoryProtocol.self)
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)

        let vm = HummingResultViewModel(
            hummingResultRepository: hummingResultRepository,
            gameStatusRepository: gameStatusRepository,
            playerRepository: playerRepository,
            roomActionRepository: roomActionRepository,
            roomInfoRepository: roomInfoRepository,
            dataDownloadRepository: dataDownloadRepository
        )
        let vc = HummingResultViewController(viewModel: vm)

        let guideVC = GuideViewController(type: .result) { [weak self] in
            guard let self else { return }
            navigationController.pushViewController(vc, animated: true)
            setupNavigationBar(for: vc)
        }
        navigationController.pushViewController(guideVC, animated: true)
    }

    private func leaveRoom() {
        Task {
            do {
                _ = try await roomActionRepository.leaveRoom()
            } catch {
                let error = ASErrors(type: .leaveRoom, reason: error.localizedDescription, file: #file, line: #line)
                LogHandler.handleError(error)
            }
        }
    }
}
