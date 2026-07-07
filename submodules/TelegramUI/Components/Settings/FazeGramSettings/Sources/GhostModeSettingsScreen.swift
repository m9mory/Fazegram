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
    private var switchChangedActions: [(Bool) -> Void] = []
    private var uiSetupDone = false

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
    }

    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        self.displayNode.frame = CGRect(origin: .zero, size: layout.size)

        if !uiSetupDone {
            uiSetupDone = true
            setupUI(with: layout.size)
        }
    }

    private func setupUI(with size: CGSize) {
        let theme = presentationDataValue.theme
        let scrollView = UIScrollView(frame: CGRect(origin: .zero, size: size))
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = theme.list.plainBackgroundColor

        let items: [(title: String, get: () -> Bool, set: (Bool) -> Void)] = [
            (
                title: "Скрыть прочтение",
                get: { FazeGramSettings.shared.hideReadReceipts },
                set: { [weak self] v in
                    guard let self = self else { return }
                    FazeGramSettings.shared.hideReadReceipts = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideReadReceipts = v; return s }.start()
                }
            ),
            (
                title: "Скрыть просмотр сторис",
                get: { FazeGramSettings.shared.hideStoryViews },
                set: { [weak self] v in
                    guard let self = self else { return }
                    FazeGramSettings.shared.hideStoryViews = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideStoryViews = v; return s }.start()
                }
            ),
            (
                title: "Скрыть онлайн",
                get: { FazeGramSettings.shared.hideOnline },
                set: { [weak self] v in
                    guard let self = self else { return }
                    FazeGramSettings.shared.hideOnline = v
                    let _ = updateFazeGramSettings(accountManager: self.ctx.sharedContext.accountManager) { s in var s = s; s.hideOnline = v; return s }.start()
                }
            ),
        ]

        self.switchChangedActions = items.map { $0.set }

        let width = size.width
        var y: CGFloat = 20.0
        let itemHeight: CGFloat = 44.0

        for (index, item) in items.enumerated() {
            let isFirst = index == 0
            let isLast = index == items.count - 1

            let container = UIView(frame: CGRect(x: 16, y: y, width: width - 32, height: itemHeight))
            container.backgroundColor = theme.list.itemBlocksBackgroundColor

            if isFirst {
                container.layer.cornerRadius = 10
                container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if isLast {
                container.layer.cornerRadius = 10
                container.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            container.clipsToBounds = true

            let label = UILabel()
            label.text = item.title
            label.font = Font.regular(17.0)
            label.textColor = theme.list.itemPrimaryTextColor
            label.sizeToFit()
            label.frame = CGRect(x: 16, y: (itemHeight - label.frame.height) / 2, width: label.frame.width, height: label.frame.height)
            container.addSubview(label)

            let toggle = UISwitch()
            toggle.isOn = item.get()
            toggle.onTintColor = theme.list.itemAccentColor
            toggle.sizeToFit()
            toggle.frame = CGRect(x: container.frame.width - toggle.frame.width - 16, y: (itemHeight - toggle.frame.height) / 2, width: toggle.frame.width, height: toggle.frame.height)
            toggle.tag = index
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            container.addSubview(toggle)

            scrollView.addSubview(container)
            y += itemHeight + 1
        }

        scrollView.contentSize = CGSize(width: width, height: y + 20)
        self.displayNode.view.addSubview(scrollView)
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        guard sender.tag < self.switchChangedActions.count else { return }
        self.switchChangedActions[sender.tag](sender.isOn)
    }
}

public func ghostModeSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    return GhostModeController(context: context, presentationData: presentationData)
}
