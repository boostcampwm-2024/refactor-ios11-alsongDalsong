import UIKit

final class GuideLabel: UILabel {
    init(style: UIFont.TextStyle = .largeTitle) {
        super.init(frame: .zero)
        font = .font(forTextStyle: style)
        textColor = .label
        textAlignment = .center
        numberOfLines = 0
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
