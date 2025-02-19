import ASContainer
import ASEntity
import ASRepositoryProtocol
import UIKit

final class TutorialGuideViewController: UIViewController {
    private let type: TutorialViewType
    private let titleLabel = GuideLabel(style: .largeTitle)
    private let descriptionLabel = GuideLabel(style: .title2)
    private let cautionLabel = GuideLabel(style: .callout)
    private var imageContainerView: GuideIconView?
    private let topButton = ASButton()
    private let bottomButton = ASButton()

    private let avatars: [URL]?
    private let selectedAvatar: URL?
    private let avatarData: Data?
    private let inviteCode: String?

    private let player: TutorialPlayer?
    private let aiPlayer1: TutorialPlayer?
    private let aiPlayer2: TutorialPlayer?

    init(
        type: TutorialViewType,
        avatars: [URL]? = nil,
        selectedAvatar: URL? = nil,
        avatarData: Data? = nil,
        inviteCode: String? = nil,
        player: TutorialPlayer? = nil,
        aiPlayer1: TutorialPlayer? = nil,
        aiPlayer2: TutorialPlayer? = nil
    ) {
        self.type = type
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
        self.inviteCode = inviteCode
        self.player = player
        self.aiPlayer1 = aiPlayer1
        self.aiPlayer2 = aiPlayer2
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupImageView()
        setAction()
        startAnimation()
    }

    private func setupUI() {
        navigationController?.navigationBar.tintColor = .asBlack

        if type == .lobby || type == .finished {
            navigationController?.navigationBar.isHidden = true
        } else {
            navigationController?.navigationBar.isHidden = false
        }
        view.backgroundColor = .asLightGray

        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButtonAction = UIAction { [weak self] _ in
            let alert = DefaultAlertController(
                titleText: .back,
                primaryButtonText: .back,
                secondaryButtonText: .cancel
            ) { [weak self] _ in
                if self?.type == .selectMusic || self?.type == .finished {
                    self?.navigationController?.navigationBar.isHidden = true
                }
                self?.navigationController?.popViewController(animated: true)
            }
            self?.navigationController?.presentAlert(alert)
        }
        let backButton = UIBarButtonItem(image: backButtonImage, primaryAction: backButtonAction)

        navigationItem.leftBarButtonItem = backButton

        titleLabel.text = type.title.localized()
        descriptionLabel.text = type.description.localized()
        cautionLabel.isHidden = true

        if let caution = type.caution {
            cautionLabel.isHidden = false
            cautionLabel.text = caution.localized()
            cautionLabel.textColor = .systemRed
        }

        if let symbol = type.symbol {
            let image = UIImage(systemName: symbol.systemName)
            let backgroundColor = UIColor(hex: symbol.color)
            let corneredImageView = GuideIconView(
                image: image,
                backgroundColor: backgroundColor
            )
            corneredImageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView = corneredImageView
        }

        topButton.setConfiguration(
            systemImageName: type.topButton.imageName,
            text: type.topButton.text.localized(),
            backgroundColor: UIColor(named: type.topButton.backgroundColor)
        )

        bottomButton.setConfiguration(
            systemImageName: type.bottomButton.imageName,
            text: type.bottomButton.text.localized(),
            backgroundColor: UIColor(named: type.bottomButton.backgroundColor)
        )

        topButton.isHidden = type.topButton.isHidden
        bottomButton.isHidden = type.bottomButton.isHidden
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(cautionLabel)
        view.addSubview(topButton)
        view.addSubview(bottomButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cautionLabel.translatesAutoresizingMaskIntoConstraints = false
        topButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -48),
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -50),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            cautionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            cautionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            cautionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            topButton.bottomAnchor.constraint(equalTo: bottomButton.topAnchor, constant: -25),
            topButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            topButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            topButton.heightAnchor.constraint(equalToConstant: 64),

            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    private func setupImageView() {
        if let imageContainerView {
            view.addSubview(imageContainerView)
            NSLayoutConstraint.activate([
                imageContainerView.widthAnchor.constraint(equalToConstant: 32),
                imageContainerView.heightAnchor.constraint(equalToConstant: 32),
                imageContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
                imageContainerView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            ])
        }
    }

    private func startAnimation() {
        imageContainerView?.animateBounces()
    }

    private func setAction() {
        topButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            switch type {
                case .lobby:
                    navigateToSelectMusicGuide()
                default:
                    return
            }
        }, for: .touchUpInside)

        bottomButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            switch type {
                case .lobby:
                    navigateToOnboarding()
                case .selectMusic:
                    navigateToSelectMusic()
                case .humming:
                    navigateToHumming()
                case .rehumming:
                    navigateToRehumming()
                case .submitAnswer:
                    navigateToSubmitAnswer()
                case .result:
                    navigateToResult()
                case .finished:
                    navigateToOnboarding()
            }
        }, for: .touchUpInside)
    }
}

private extension TutorialGuideViewController {
    func navigateToOnboarding() {
        guard let avatars,
              let selectedAvatar,
              let avatarData,
              let inviteCode
        else { return }

        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)

        let onboardingVM = OnboardingViewModel(
            roomActionRepository: roomActionRepository,
            dataDownloadRepository: dataDownloadRepository,
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData
        )
        let onboardingVC = OnboardingViewController(
            viewModel: onboardingVM,
            inviteCode: inviteCode
        )
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    func navigateToSelectMusicGuide() {
        let tutorialViewController = TutorialGuideViewController(
            type: .selectMusic,
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(tutorialViewController, animated: true)
    }

    func navigateToSelectMusic() {
        let selectMusicViewController = SelectMusicTutorialViewController(
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(selectMusicViewController, animated: true)
    }

    func navigateToHumming() {
        let hummingViewController = HummingTutorialViewController(
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(hummingViewController, animated: true)
    }

    func navigateToRehumming() {
        let rehummingViewController = RehummingTutorialViewController(
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(rehummingViewController, animated: true)
    }
    
    func navigateToSubmitAnswer() {
        let submitAnswerViewController = SubmitAnswerTutorialViewController(
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(submitAnswerViewController, animated: true)
    }
    
    func navigateToResultGuide() {
        let tutorialViewController = TutorialGuideViewController(
            type: .result,
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(tutorialViewController, animated: true)
    }

    func navigateToResult() {
        let hummingResultViewController = HummingResultTutorialViewController(
            avatars: avatars,
            selectedAvatar: selectedAvatar,
            avatarData: avatarData,
            inviteCode: inviteCode,
            selectedMusic: Music(),
            recordedData: Data(),
            player: player,
            aiPlayer1: aiPlayer1,
            aiPlayer2: aiPlayer2
        )
        navigationController?.pushViewController(hummingResultViewController, animated: true)
    }
}
