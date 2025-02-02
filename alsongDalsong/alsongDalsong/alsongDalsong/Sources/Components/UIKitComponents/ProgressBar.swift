import Combine
import UIKit

final class ProgressBar: UIView {
    private let progressBar = UIView()
    private var cancellables = Set<AnyCancellable>()
    private var targetDate: Date?
    private var progressBarWidthConstraint: NSLayoutConstraint?

    typealias CompletionHandler = () -> Void
    private var completionHandler: CompletionHandler?
    private var isCancelled = false
    private var didSetInitialWidth = false
    private var isAnimating = false

    init() {
        super.init(frame: .zero)
        setupProgressBar()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(
        to dataSource: Published<Date?>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDate in
                self?.targetDate = newDate
                self?.startProgressAnimation()
            }
            .store(in: &cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !didSetInitialWidth, !isAnimating else { return }
        
        progressBarWidthConstraint?.constant = bounds.width
        didSetInitialWidth = true
    }

    func setCompletionHandler(_ handler: @escaping CompletionHandler) {
        completionHandler = handler
    }

    func cancelCompletion() {
        isCancelled = true
    }

    private func setupProgressBar() {
        progressBar.backgroundColor = .asYellow
        addSubview(progressBar)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBarWidthConstraint!,
        ])
    }

    private func startProgressAnimation() {
        guard let targetDate else { return }
        let timeInterval = targetDate.timeIntervalSince(Date.now)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        isAnimating = true
        
        UIView.animate(
            withDuration: timeInterval,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.isAnimating = false
                self.progressBarWidthConstraint?.constant = 0
                self.layoutIfNeeded()
            },
            completion: { _ in
                if !self.isCancelled {
                    self.completionHandler?()
                    return
                }
            }
        )
    }
}
