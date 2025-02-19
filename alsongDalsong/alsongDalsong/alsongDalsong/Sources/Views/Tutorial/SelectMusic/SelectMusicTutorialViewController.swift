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
            self?.updatePlayers()

            let tutorialViewController = TutorialGuideViewController(
                type: .humming,
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

private extension SelectMusicTutorialViewController {
    func updatePlayers() {
        player?.selectedMusic = selectedMusic
        if player?.selectedMusic == TutorialData.loser {
            aiPlayer1?.selectedMusic = TutorialData.superShy
            aiPlayer2?.selectedMusic = TutorialData.theMoonOfSeoul
        } else if player?.selectedMusic == TutorialData.superShy {
            aiPlayer1?.selectedMusic = TutorialData.theMoonOfSeoul
            aiPlayer2?.selectedMusic = TutorialData.loser
        } else if player?.selectedMusic == TutorialData.theMoonOfSeoul {
            aiPlayer1?.selectedMusic = TutorialData.loser
            aiPlayer2?.selectedMusic = TutorialData.superShy
        }
    }
}

//@available(iOS 17, *)
//#Preview {
//    UINavigationController(rootViewController: SelectMusicTutorialViewController(
//        avatars: nil,
//        selectedAvatar: nil,
//        avatarData: nil,
//        inviteCode: nil
//    ))
//}
