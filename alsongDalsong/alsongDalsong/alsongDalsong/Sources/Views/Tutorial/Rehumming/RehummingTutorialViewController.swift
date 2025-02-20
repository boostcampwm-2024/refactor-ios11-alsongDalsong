import ASAIKit
import ASEntity
import UIKit

final class RehummingTutorialViewController: UIViewController {
    private let progressBar = ProgressBar()
    private let scrollView = UIScrollView()
    private let musicPanel = MusicPanel()
    private let hummingPanel = RecordingPanel(.asYellow)
    private let recordButton = ASButton()
    private let submitButton = ASButton()
    private let buttonStack = UIStackView()

    private let viewModel: RehummingTutorialViewModel
    private let avatars: [URL]?
    private let selectedAvatar: URL?
    private let avatarData: Data?
    private let inviteCode: String?

    private var player: TutorialPlayer?
    private var aiPlayer1: TutorialPlayer?
    private var aiPlayer2: TutorialPlayer?

    init(
        avatars: [URL]?,
        selectedAvatar: URL?,
        avatarData: Data?,
        inviteCode: String?,
        player: TutorialPlayer?,
        aiPlayer1: TutorialPlayer?,
        aiPlayer2: TutorialPlayer?
    ) {
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
        self.inviteCode = inviteCode
        self.player = player
        self.aiPlayer1 = aiPlayer1
        self.aiPlayer2 = aiPlayer2
        self.viewModel = RehummingTutorialViewModel(
            selectedMusic: Music(
                id: "",
                title: nil,
                artist: nil,
                artworkUrl: Bundle.main.url(forResource: "AreYouCrazyHuman", withExtension: "png"),
                previewUrl: aiPlayer1?.hummingURL,
                artworkBackgroundColor: nil
            )
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBind()
        setupAction()
        setupUI()
        setupLayout()
    }

    private func setupBind() {
        musicPanel.bind(to: viewModel.$panelData)
        hummingPanel.bind(to: viewModel.$isRecording)
        hummingPanel.onRecordingFinished = { [weak self] data in
            self?.recordButton.updateButton(.reRecord)
            self?.viewModel.recordedData = data
        }
        submitButton.bind(to: viewModel.$recordedData)
    }

    private func setupUI() {
        view.backgroundColor = .asLightGray
        title = "리허밍"

        recordButton.updateButton(.startRecord)
        submitButton.updateButton(.submit)
        submitButton.updateButton(.disabled)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(recordButton)
        buttonStack.addArrangedSubview(submitButton)

        scrollView.addSubview(musicPanel)
        scrollView.addSubview(hummingPanel)

        view.addSubview(progressBar)
        view.addSubview(scrollView)
        view.addSubview(buttonStack)

        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .asBlack
        let defaultFontSize = UIFont.preferredFont(forTextStyle: .headline).pointSize as CGFloat?
        var fontStyle = UIFont()
        if let defaultFontSize {
            fontStyle = .font(.dohyeon, ofSize: defaultFontSize)
        } else {
            fontStyle = .font(.dohyeon, ofSize: 18)
        }
        navigationController?.navigationBar.titleTextAttributes = [.font: fontStyle]

        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButtonAction = UIAction { [weak self] _ in
            let alert = DefaultAlertController(
                titleText: .back,
                primaryButtonText: .back,
                secondaryButtonText: .cancel
            ) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            self?.navigationController?.presentAlert(alert)
        }
        let backButton = UIBarButtonItem(image: backButtonImage, primaryAction: backButtonAction)

        navigationItem.leftBarButtonItem = backButton
    }

    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        musicPanel.translatesAutoresizingMaskIntoConstraints = false
        hummingPanel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),

            scrollView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: hummingPanel.bottomAnchor, constant: 16),

            musicPanel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
            musicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            musicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            hummingPanel.topAnchor.constraint(equalTo: musicPanel.bottomAnchor, constant: 32),
            hummingPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hummingPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hummingPanel.heightAnchor.constraint(equalToConstant: 84),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
        ])
    }

    private func setupAction() {
        recordButton.addAction(UIAction { [weak self] _ in
            self?.recordButton.updateButton(.recording)
            self?.viewModel.isRecording = true
        }, for: .touchUpInside)

        submitButton.addAction(UIAction { [weak self] _ in
            self?.updatePlayers()
            let tutorialViewController = TutorialGuideViewController(
                type: .submitAnswer,
                avatars: self?.avatars,
                selectedAvatar: self?.selectedAvatar,
                avatarData: self?.avatarData,
                inviteCode: self?.inviteCode,
                player: self?.player,
                aiPlayer1: self?.aiPlayer1,
                aiPlayer2: self?.aiPlayer2
            )
            self?.navigationController?.pushViewController(tutorialViewController, animated: true)
        }, for: .touchUpInside)
    }
}

extension RehummingTutorialViewController {
    func updatePlayers() {
        guard let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        try? viewModel.recordedData?.write(to: fileURL)
        player?.rehummingURL = fileURL
        aiPlayer1?.rehummingURL = aiPlayer2?.hummingURL
        guard let aiHumming = ASAIAnalyzer.m4aToMIDI(audioURL: player?.hummingURL) else {
            if player?.selectedMusic == TutorialData.loser {
                aiPlayer2?.rehummingURL = Bundle.main.url(forResource: "Loser", withExtension: "mid")
            } else if player?.selectedMusic == TutorialData.superShy {
                aiPlayer2?.rehummingURL = Bundle.main.url(forResource: "Super Shy", withExtension: "mid")
            } else if player?.selectedMusic == TutorialData.theMoonOfSeoul {
                aiPlayer2?.rehummingURL = Bundle.main.url(forResource: "Moon of Seoul", withExtension: "mid")
            }
            return
        }
        aiPlayer2?.rehummingURL = aiHumming
    }
}

@available(iOS 17, *)
#Preview {
    UINavigationController(rootViewController: RehummingTutorialViewController(
        avatars: nil,
        selectedAvatar: nil,
        avatarData: nil,
        inviteCode: nil,
        player: nil,
        aiPlayer1: nil,
        aiPlayer2: nil
    ))
}
