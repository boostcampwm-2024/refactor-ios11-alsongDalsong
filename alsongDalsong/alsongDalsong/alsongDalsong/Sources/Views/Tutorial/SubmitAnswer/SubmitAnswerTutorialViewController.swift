import SwiftUI

final class SubmitAnswerTutorialViewController: UIViewController {
    private var progressBar = ProgressBar()
    private let scrollView = UIScrollView()
    private var musicPanel = MusicPanel()
    private var selectedMusicPanel = MusicPanel(.compact)
    private var selectAnswerButton = ASButton()
    private let submitButton = ASButton()
    private var buttonStack = UIStackView()
    
    private let viewModel = SubmitAnswerTutorialViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBind()
        setupAction()
        setupUI()
        setupLayout()
        setupStyle()
    }
    
    private func setupUI() {
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
            // next view
            }, for: .touchUpInside
        )
    }
}

@available(iOS 17, *)
#Preview {
    SubmitAnswerTutorialViewController()
}
