import SwiftUI
import ASEntity

final class SubmitAnswerTutorialViewController: UIViewController {
    private var progressBar = ProgressBar()
    private let scrollView = UIScrollView()
    private var musicPanel = MusicPanel()
    private var selectedMusicPanel = MusicPanel(.compact)
    private var selectAnswerButton = ASButton()
    private let submitButton = ASButton()
    private var buttonStack = UIStackView()
    
    private let viewModel: SubmitAnswerTutorialViewModel
    
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
        viewModel = SubmitAnswerTutorialViewModel(
            humming: Music(
                id: "",
                title: nil,
                artist: nil,
                artworkUrl: Bundle.main.url(forResource: "AreYouCrazyHuman", withExtension: "png"),
                previewUrl: aiPlayer1?.rehummingURL,
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
        setupStyle()
    }
    
    private func setupUI() {
        title = "정답 선택"
        
        selectAnswerButton.setConfiguration(text: String(localized: "정답 선택"), backgroundColor: .asLightSky)
        submitButton.setConfiguration(text: String(localized: "정답 제출"), backgroundColor: .asLightGray)
        submitButton.updateButton(.disabled)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(selectAnswerButton)
        buttonStack.addArrangedSubview(submitButton)
       
        scrollView.addSubview(musicPanel)
        scrollView.addSubview(selectedMusicPanel)
        
        view.addSubview(progressBar)
        view.addSubview(scrollView)
        view.addSubview(buttonStack)
        
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
        selectedMusicPanel.translatesAutoresizingMaskIntoConstraints = false
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
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: selectedMusicPanel.bottomAnchor, constant: 16),

            musicPanel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            musicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            musicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            selectedMusicPanel.topAnchor.constraint(equalTo: musicPanel.bottomAnchor, constant: 32),
            selectedMusicPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedMusicPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedMusicPanel.heightAnchor.constraint(equalToConstant: 100),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
        ])
    }
    
    private func setupStyle() {
        view.backgroundColor = .asLightGray
    }
    
    private func setupBind() {
        musicPanel.bind(to: viewModel.$humming)
        selectedMusicPanel.bind(to: viewModel.$selectedMusic)
        submitButton.bind(to: viewModel.$selectedMusicData)
    }
    
    private func setupAction() {
        selectAnswerButton.addAction(
            UIAction { [weak self] _ in
                let musicView = SelectMusicTutorialView { music in
                    self?.viewModel.selectedMusic = music
                    self?.viewModel.selectedMusicData = Data()
                }
                let viewController = UIHostingController(rootView: musicView)
                self?.present(viewController, animated: true)
            }, for: .touchUpInside)
        
        submitButton.addAction(
            UIAction { [weak self] _ in
                Task {
                    await AudioHelper.shared.stopPlaying()
                }
                
                self?.player?.submittedMusic = self?.viewModel.selectedMusic
                self?.aiPlayer1?.submittedMusic = nil
                self?.aiPlayer2?.submittedMusic = nil

                let tutorialViewController = TutorialGuideViewController(
                    type: .result,
                    avatars: self?.avatars,
                    selectedAvatar: self?.selectedAvatar,
                    avatarData: self?.avatarData,
                    inviteCode: self?.inviteCode,
                    player: self?.player,
                    aiPlayer1: self?.aiPlayer1,
                    aiPlayer2: self?.aiPlayer2
                )

                self?.navigationController?.pushViewController(tutorialViewController, animated: true)
            }, for: .touchUpInside
        )
    }
}

@available(iOS 17, *)
#Preview {
    SubmitAnswerTutorialViewController(
        avatars: nil,
        selectedAvatar: nil,
        avatarData: nil,
        inviteCode: nil,
        player: nil,
        aiPlayer1: nil,
        aiPlayer2: nil
    )
}
