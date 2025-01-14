import ASContainer
import ASRepositoryProtocol
import Combine
import UIKit

final class LoadingViewController: UIViewController {
    private var logoImageView = UIImageView(image: UIImage(named: "logo"))
    private var viewModel: LoadingViewModel?
    private var inviteCode = ""
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: LoadingViewModel, inviteCode: String) {
        self.viewModel = viewModel
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        [logoImageView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 356),
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48)
        ])
    }
    
    private func bindViewModel() {
        bind(viewModel?.$avatarData) { [weak self] data in
            guard let data else { return }
            self?.navigateOnboarding()
        }
    }
    
    private func bind<T>(
        _ publisher: Published<T>.Publisher?,
        handler: @escaping (T) -> Void
    ) {
        publisher?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    private func navigateOnboarding() {
        let roomActionRepository = DIContainer.shared.resolve(RoomActionRepositoryProtocol.self)
        let dataDownloadRepository = DIContainer.shared.resolve(DataDownloadRepositoryProtocol.self)
        
        let onboardingVM = OnboardingViewModel(
            roomActionRepository: roomActionRepository,
            dataDownloadRepository: dataDownloadRepository,
            avatars: viewModel?.avatars ?? [],
            selectedAvatar: viewModel?.selectedAvatar,
            avatarData: viewModel?.avatarData
        )
        let onboardingVC = OnboardingViewController(
            viewModel: onboardingVM,
            inviteCode: inviteCode
        )
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.navigationBar.isHidden = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
