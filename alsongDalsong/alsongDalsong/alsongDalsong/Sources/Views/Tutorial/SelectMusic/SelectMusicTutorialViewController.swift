import ASEntity
import SwiftUI

final class SelectMusicTutorialViewController: UIViewController {
    private let progressBar = ProgressBar()
    private let submitButton = ASButton()
    
    private var selectMusicView = UIViewController()
    private var selectedMusic: Music?

    private let avatars: [URL]?
    private let selectedAvatar: URL?
    private let avatarData: Data?
    private let inviteCode: String?

    init(avatars: [URL]?, selectedAvatar: URL?, avatarData: Data?, inviteCode: String?) {
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAction()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        title = "노래 선택"

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

        let musicView = SelectMusicTutorialView { [weak self] music in
            self?.selectedMusic = music
            self?.submitButton.updateButton(.submit)
            self?.submitButton.isEnabled = true
        }
        selectMusicView = UIHostingController(rootView: musicView)
        
        submitButton.setConfiguration(text: String(localized: "선택 완료"), backgroundColor: .asGreen)
        submitButton.updateButton(.disabled)
        
        view.addSubview(progressBar)
        view.addSubview(selectMusicView.view)
        view.addSubview(submitButton)
    }
    
    private func setupLayout() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        selectMusicView.view.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 16),
            
            selectMusicView.view.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            selectMusicView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectMusicView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectMusicView.view.bottomAnchor.constraint(equalTo: submitButton.topAnchor),

            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    private func setupAction() {
        submitButton.addAction(UIAction { [weak self] _ in
            Task {
                await AudioHelper.shared.stopPlaying()
            }

            let tutorialViewController = TutorialGuideViewController(
                type: .humming,
                avatars: self?.avatars,
                selectedAvatar: self?.selectedAvatar,
                avatarData: self?.avatarData,
                inviteCode: self?.inviteCode,
                selectedMusic: self?.selectedMusic
            )
            self?.navigationController?.pushViewController(tutorialViewController, animated: true)
        }, for: .touchUpInside)
    }
}

@available(iOS 17, *)
#Preview {
    UINavigationController(rootViewController: SelectMusicTutorialViewController(
        avatars: nil,
        selectedAvatar: nil,
        avatarData: nil,
        inviteCode: nil
    ))
}
