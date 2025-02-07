import ASEntity
import Combine
import UIKit

final class HummingResultTutorialViewController: UIViewController {
    private let answerView = MusicPanelView()
    private let resultTableView = UITableView()
    private let nextButton = ASButton()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var resultTableViewDiffableDataSource = HummingResultTableViewDiffableDataSource(tableView: resultTableView)
    
    private let viewModel: HummingResultTutorialViewModel
    private let avatars: [URL]?
    private let selectedAvatar: URL?
    private let avatarData: Data?
    private let inviteCode: String?
    private var selectedMusic: Music?
    private var recordedData: Data?

    init(
        avatars: [URL]?,
        selectedAvatar: URL?,
        avatarData: Data?,
        inviteCode: String?,
        selectedMusic: Music?,
        recordedData: Data?
    ) {
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
        self.avatarData = avatarData
        self.inviteCode = inviteCode
        self.selectedMusic = selectedMusic
        self.recordedData = recordedData
        self.viewModel = HummingResultTutorialViewModel(
            avatars: avatars,
            selectedMusic: selectedMusic,
            recordedData: recordedData
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
        
        viewModel.updateResult()
    }
    
    private func setupBind() {
        answerView.bind(to: viewModel.$result)
        viewModel.bindAudio()
        
        viewModel.$resultPhase
            .combineLatest(viewModel.$result)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phase, result in
                guard let self else { return }
                addDataSource(phase, result: result)
            }
            .store(in: &cancellables)
        
        viewModel.$isTutorialFinished
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFinished in
                if isFinished {
                    self?.nextButton.setConfiguration(
                        text: String(localized: "튜토리얼 완료"),
                        backgroundColor: .asMint
                    )
                    self?.nextButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .asLightGray
        title = "결과 확인"

        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = .asBlack
        let defaultFontSize = UIFont.preferredFont(forTextStyle: .headline).pointSize as CGFloat?
        var fontStyle = UIFont()
        if let defaultFontSize {
            fontStyle = .font(.dohyeon, ofSize: defaultFontSize)
        } else {
            fontStyle = .font(.dohyeon, ofSize: 18)
        }
        navigationController?.navigationBar.titleTextAttributes = [.font: fontStyle]

        resultTableViewDiffableDataSource = HummingResultTableViewDiffableDataSource(tableView: resultTableView)
        resultTableView.separatorStyle = .none
        resultTableView.allowsSelection = false
        resultTableView.backgroundColor = .asLightGray
        resultTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        nextButton.setConfiguration(
            text: String(localized: "튜토리얼 완료"),
            backgroundColor: .asMint
        )
        nextButton.updateButton(.disabled)
        
        view.addSubview(answerView)
        view.addSubview(resultTableView)
        view.addSubview(nextButton)
    }
    
    private func setupLayout() {
        answerView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            answerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            answerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            answerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            answerView.heightAnchor.constraint(equalToConstant: 130),

            resultTableView.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 64),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupAction() {
        nextButton.addAction(UIAction { [weak self] _ in
            let tutorialViewController = TutorialGuideViewController(
                type: .finished,
                avatars: self?.avatars,
                selectedAvatar: self?.selectedAvatar,
                avatarData: self?.avatarData,
                inviteCode: self?.inviteCode
            )
            self?.navigationController?.pushViewController(tutorialViewController, animated: true)
        }, for: .touchUpInside)
    }
    
    func addDataSource(_ phase: ResultPhase, result: Result) {
        if case let .record(count) = phase {
            var updateResult = result
            let records = updateResult.records[0 ... count]
            updateResult.records = Array(records)
            updateResult.submit = nil
            resultTableViewDiffableDataSource.applySnapshot(updateResult)
            return
        }
        if case .submit = phase {
            resultTableViewDiffableDataSource.applySnapshot(result)
            return
        }
        if case .answer = phase {
            resultTableViewDiffableDataSource.applySnapshot((result.answer, [], nil))
        }
    }
}

@available(iOS 17, *)
#Preview {
    UINavigationController(rootViewController: HummingResultTutorialViewController(
        avatars: nil,
        selectedAvatar: nil,
        avatarData: nil,
        inviteCode: nil,
        selectedMusic: nil,
        recordedData: nil
    ))
}
