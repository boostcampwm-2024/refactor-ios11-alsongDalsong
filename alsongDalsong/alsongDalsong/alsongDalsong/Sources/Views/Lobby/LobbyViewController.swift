import Combine
import SwiftUI

final class LobbyViewController: UIViewController {
    private let inviteButton = ASButton()
    private let startButton = ASButton()
    private let nextButton = ASButton()
    private lazy var buttonStack = UIStackView(arrangedSubviews: [inviteButton, startButton, nextButton])
    private var lobbyView = UIViewController()
    private let viewmodel: LobbyViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(lobbyViewModel: LobbyViewModel) {
        viewmodel = lobbyViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lobbyView = UIHostingController(rootView: LobbyView(viewModel: viewmodel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setAction()
        bindToComponents()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lobbyView.view = nil
    }

    private func bindToComponents() {
        viewmodel.$canBeginGame.combineLatest(viewmodel.$isHost)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canBeginGame, isHost in
                if isHost {
                    if canBeginGame {
                        self?.startButton.updateButton(.startGame)
                        self?.startButton.isEnabled = true
                    }
                    else {
                        self?.startButton.updateButton(.needMorePlayers)
                        self?.startButton.updateButton(.disabled)
                    }
                }
                else {
                    self?.startButton.updateButton(.hostSelecting)
                    self?.startButton.updateButton(.disabled)
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .asLightGray

        inviteButton.setConfiguration(
            systemImageName: "link",
            text: String(localized: "초대하기!"),
            backgroundColor: .asYellow
        )

        startButton.setConfiguration(
            systemImageName: "play.fill",
            text: String(localized: "시작하기!"),
            backgroundColor: .asMint
        )
        
        nextButton.setConfiguration(
            systemImageName: "play.fill",
            text: String(localized: "튜토리얼 시작!"),
            backgroundColor: .asMint
        )

        lobbyView = UIHostingController(rootView: LobbyView(viewModel: viewmodel))

        view.addSubview(lobbyView.view)
        view.addSubview(buttonStack)
        buttonStack.axis = .vertical
        buttonStack.spacing = 24
        
        if viewmodel as? AILobbyViewModel != nil {
            inviteButton.isHidden = true
            startButton.isHidden = true
        } else {
            nextButton.isHidden = true
        }
    }

    private func setAction() {
        inviteButton.addAction(UIAction { [weak self] _ in
            guard let roomNumber = self?.viewmodel.roomNumber else { return }
            if let url = URL(string: "alsongDalsong://invite/?roomnumber=\(roomNumber)") {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self?.inviteButton
                self?.present(activityViewController, animated: true, completion: nil)
            }
        }, for: .touchUpInside)

        startButton.addAction(
            UIAction { [weak self] _ in
                guard let playerCount = self?.viewmodel.players.count else { return }
                playerCount < 3 ?
                    self?.showNeedMorePlayers() :
                self?.showStartGameLoading(with: .startGame)
            },
            for: .touchUpInside
        )
        
        nextButton.addAction(
            UIAction { _ in
                
            }
            , for: .touchUpInside)
    }

    private func setupLayout() {
        lobbyView.view.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lobbyView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lobbyView.view.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            lobbyView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lobbyView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            inviteButton.heightAnchor.constraint(equalToConstant: 64),
            startButton.heightAnchor.constraint(equalToConstant: 64),
            nextButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    private func gameStart() async throws {
        try await viewmodel.gameStart()
    }
}

// MARK: - Alert

extension LobbyViewController {
    func showStartGameLoading(with progressText: ASAlertText.ProgressText) {
        let alert = LoadingAlertController(
            progressText: progressText,
            loadAction: { [weak self] in
                try await self?.gameStart()
            },
            errorCompletion: { [weak self] error in
                self?.showStartGameFailed(error)
            }
        )
        presentAlert(alert)
    }

    func showNeedMorePlayers() {
        let alert = DefaultAlertController(
            titleText: .needMorePlayer,
            primaryButtonText: .keep,
            secondaryButtonText: .cancel
        ) { [weak self] _ in
            self?.showStartGameLoading(with: .startGame)
        }
        presentAlert(alert)
    }

    func showStartGameFailed(_ error: Error) {
        let alert = SingleButtonAlertController(titleText: .error(error))
        presentAlert(alert)
    }
}
