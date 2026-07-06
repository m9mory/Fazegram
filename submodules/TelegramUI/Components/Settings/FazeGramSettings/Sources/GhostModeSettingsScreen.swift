import Foundation
import UIKit
import Display
import AsyncDisplayKit
import AccountContext
import TelegramCore
import TelegramPresentationData
import SwiftSignalKit

private final class GhostModeController: ViewController {
    private let ctx: AccountContext
    private var presentationDataValue: PresentationData

    init(context: AccountContext, presentationData: PresentationData) {
        self.ctx = context
        self.presentationDataValue = presentationData
        super.init(navigationBarPresentationData: nil)
        self.title = "Fazegram"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadDisplayNode() {
        self.displayNode = ASDisplayNode()
        self.displayNode.backgroundColor = presentationDataValue.theme.list.plainBackgroundColor
        self.displayNodeDidLoad()
        setupUI()
    }

    private func setupUI() {
        let theme = presentationDataValue.theme
        let scrollView = UIScrollView(frame: self.displayNode.bounds)
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = theme.list.plainBackgroundColor

        let items: [(title: String, get: () -> Bool, set: (Bool) -> Void)] = [
            (
                title: "Скрыть прочтение",
                get: { FazeGramSettings.shared.hideReadReceipts },
                set: { v in
                    FazeGramSettings.shared.hideReadReceipts = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideReadReceipts = v; return s }.start()
                }
            ),
            (
                title: "Скрыть просмотр сторис",
                get: { FazeGramSettings.shared.hideStoryViews },
                set: { v in
                    FazeGramSettings.shared.hideStoryViews = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideStoryViews = v; return s }.start()
                }
            ),
            (
                title: "Скрыть онлайн",
                get: { FazeGramSettings.shared.hideOnline },
                set: { v in
                    FazeGramSettings.shared.hideOnline = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideOnline = v; return s }.start()
                }
            ),
        ]

        var y: CGFloat = 20.0
        let itemHeight: CGFloat = 44.0
        let width = self.displayNode.bounds.width

        for (_, item) in items.enumerated() {
            let container = UIView(frame: CGRect(x: 16, y: y, width: width - 32, height: itemHeight))
            container.backgroundColor = theme.list.itemBlocksBackgroundColor
            container.layer.cornerRadius = 10
            container.clipsToBounds = true

            let label = UILabel(frame: CGRect(x: 16, y: 0, width: container.bounds.width - 80, height: itemHeight))
            label.text = item.title
            label.font = Font.regular(17.0)
            label.textColor = theme.list.itemPrimaryTextColor
            container.addSubview(label)

            let toggle = UISwitch()
            toggle.isOn = item.get()
            toggle.onTintColor = theme.list.itemAccentColor
            toggle.frame = CGRect(x: container.bounds.width - 67, y: (itemHeight - 31) / 2, width: 51, height: 31)
            toggle.addAction(UIAction { _ in
                item.set(toggle.isOn)
            }, for: .valueChanged)
            container.addSubview(toggle)

            scrollView.addSubview(container)
            y += itemHeight + 1
        }

        scrollView.contentSize = CGSize(width: width, height: y + 20)
        self.displayNode.view.addSubview(scrollView)
    }

    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        self.displayNode.frame = CGRect(origin: .zero, size: layout.size)
        if let scrollView = self.displayNode.view.subviews.first as? UIScrollView {
            scrollView.frame = CGRect(origin: .zero, size: layout.size)
        }
    }
}

public func ghostModeSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    return GhostModeController(context: context, presentationData: presentationData)
}
