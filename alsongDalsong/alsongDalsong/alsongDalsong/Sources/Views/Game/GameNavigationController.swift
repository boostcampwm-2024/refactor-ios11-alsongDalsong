import UIKit

@MainActor
class GameNavigationController: @unchecked Sendable {
    let navigationController: UINavigationController
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func setConfiguration() {}
    func setFont() -> FontName { .dohyeon }
    func navigateToLobby() {
        if navigationController.topViewController is LobbyViewController { return }

        if let vc = navigationController.viewControllers.first(where: { $0 is LobbyViewController }) {
            navigationController.popToViewController(vc, animated: true)
            return
        }
    }
    func setupNavigationBar(for viewController: UIViewController) {
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.tintColor = .asBlack
        let defaultFontSize = UIFont.preferredFont(forTextStyle: .headline).pointSize as CGFloat?
        var fontStyle = UIFont()
        if let defaultFontSize {
            fontStyle = .font(setFont(), ofSize: defaultFontSize)
        } else {
            fontStyle = .font(setFont(), ofSize: 18)
        }
        navigationController.navigationBar.titleTextAttributes = [.font: fontStyle]
    }
}
