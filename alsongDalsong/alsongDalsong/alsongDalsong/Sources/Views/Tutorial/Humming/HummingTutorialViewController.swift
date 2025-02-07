import ASEntity
import UIKit

final class HummingTutorialViewController: UIViewController {
    private let progressBar = ProgressBar()
    private let scrollView = UIScrollView()
    private let musicPanel = MusicPanel()
    private let hummingPanel = RecordingPanel(.asYellow)
    private let recordButton = ASButton()
    private let submitButton = ASButton()
    private let buttonStack = UIStackView()
    
    private let viewModel: HummingTutorialViewModel
    private let avatars: [URL]?
    private let selectedAvatar: URL?
    private let avatarData: Data?
    private let inviteCode: String?
    private let selectedMusic: Music?

    init(
        avatars: [URL]?,
        selectedAvatar: URL?,
        avatarData: Data?,
        inviteCode: String?,
        selectedMusic: Music?
    ) {
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
        self.inviteCode = inviteCode
        self.selectedMusic = selectedMusic
        self.viewModel = HummingTutorialViewModel(selectedMusic: selectedMusic)
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
        title = "허밍"

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
            let tutorialViewController = TutorialGuideViewController(
                type: .submitAnswer,
                avatars: self?.avatars,
                selectedAvatar: self?.selectedAvatar,
                avatarData: self?.avatarData,
                inviteCode: self?.inviteCode,
                selectedMusic: self?.selectedMusic,
                recordedData: self?.viewModel.recordedData
            )
            self?.navigationController?.pushViewController(tutorialViewController, animated: true)
        }, for: .touchUpInside)
    }
}

@available(iOS 17, *)
#Preview {
    UINavigationController(rootViewController: HummingTutorialViewController(
        avatars: nil,
        selectedAvatar: nil,
        avatarData: nil,
        inviteCode: nil,
        selectedMusic: nil
    ))
}
