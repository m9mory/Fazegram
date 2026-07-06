import Foundation
import UIKit
import Display
import AccountContext
import TelegramCore
import TelegramPresentationData
import SwiftSignalKit

public func ghostModeSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    let theme = presentationData.theme
    let strings = presentationData.strings

    class GhostModeController: ViewController {
        private let context: AccountContext
        private var hideReadReceipts: Bool = FazeGramSettings.shared.hideReadReceipts
        private var hideStoryViews: Bool = FazeGramSettings.shared.hideStoryViews
        private var hideOnline: Bool = FazeGramSettings.shared.hideOnline

        init(context: AccountContext) {
            self.context = context
            super.init(navigationBarPresentationData: NavigationBarPresentationData(
                theme: NavigationBarTheme(
                    overallDarkAppearance: theme.overallDarkAppearance,
                    buttonColor: theme.rootController.navigationBar.accentTextColor,
                    disabledButtonColor: theme.rootController.navigationBar.disabledButtonColor,
                    primaryTextColor: theme.rootController.navigationBar.primaryTextColor,
                    backgroundColor: .clear,
                    opaqueBackgroundColor: .clear,
                    enableBackgroundBlur: false,
                    separatorColor: .clear,
                    badgeBackgroundColor: theme.rootController.navigationBar.badgeBackgroundColor,
                    badgeStrokeColor: theme.rootController.navigationBar.badgeStrokeColor,
                    badgeTextColor: theme.rootController.navigationBar.badgeTextColor,
                    edgeEffectColor: .clear,
                    accentButtonColor: theme.rootController.navigationBar.accentTextColor,
                    accentDisabledButtonColor: theme.rootController.navigationBar.disabledButtonColor,
                    accentForegroundColor: theme.rootController.navigationBar.accentTextColor,
                    style: .solid
                ),
                strings: NavigationBarStrings(
                    back: "Fazegram",
                    close: strings.Common_Close
                )
            ))
            self.title = "Fazegram"
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func loadDisplayNode() {
            self.displayNode = ASDisplayNode()
            self.displayNode.backgroundColor = theme.list.plainBackgroundColor
            self.displayNodeDidLoad()
        }

        override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
            super.containerLayoutUpdated(layout, transition: transition)

            if let scrollNode = self.displayNode.view.subviews.first as? UIScrollView {
                scrollNode.frame = CGRect(origin: .zero, size: layout.size)
            } else {
                setupUI(layout: layout)
            }
        }

        private func setupUI(layout: ContainerViewLayout) {
            let scrollView = UIScrollView(frame: CGRect(origin: .zero, size: layout.size))
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = theme.list.plainBackgroundColor

            let items: [(String, Bool, (Bool) -> Void)] = [
                (title: "Скрыть прочтение", value: hideReadReceipts, toggle: { [weak self] v in
                    self?.hideReadReceipts = v
                    FazeGramSettings.shared.hideReadReceipts = v
                    let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { settings in
                        var s = settings
                        s.hideReadReceipts = v
                        return s
                    }.start()
                }),
                (title: "Скрыть просмотр сторис", value: hideStoryViews, toggle: { [weak self] v in
                    self?.hideStoryViews = v
                    FazeGramSettings.shared.hideStoryViews = v
                    let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { settings in
                        var s = settings
                        s.hideStoryViews = v
                        return s
                    }.start()
                }),
                (title: "Скрыть онлайн", value: hideOnline, toggle: { [weak self] v in
                    self?.hideOnline = v
                    FazeGramSettings.shared.hideOnline = v
                    let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { settings in
                        var s = settings
                        s.hideOnline = v
                        return s
                    }.start()
                }),
            ]

            var y: CGFloat = 20.0
            let itemHeight: CGFloat = 44.0
            let width = layout.size.width

            for (index, item) in items.enumerated() {
                let hasTopRadius = index == 0
                let hasBottomRadius = index == items.count - 1

                let container = UIView(frame: CGRect(x: 16, y: y, width: width - 32, height: itemHeight))
                container.backgroundColor = theme.list.itemBlocksBackgroundColor

                if hasTopRadius && hasBottomRadius {
                    container.layer.cornerRadius = 10
                    container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else if hasTopRadius {
                    container.layer.cornerRadius = 10
                    container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else if hasBottomRadius {
                    container.layer.cornerRadius = 10
                    container.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
                container.clipsToBounds = true

                let label = UILabel(frame: CGRect(x: 16, y: 0, width: container.bounds.width - 80, height: itemHeight))
                label.text = item.0
                label.font = Font.regular(17.0)
                label.textColor = theme.list.itemPrimaryTextColor
                container.addSubview(label)

                let toggle = UISwitch()
                toggle.isOn = item.1
                toggle.onTintColor = theme.list.itemAccentColor
                toggle.frame = CGRect(x: container.bounds.width - 67, y: (itemHeight - 31) / 2, width: 51, height: 31)
                toggle.tag = index
                toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                container.addSubview(toggle)

                scrollView.addSubview(container)
                y += itemHeight + 1
            }

            self.displayNode.view.addSubview(scrollView)
        }

        @objc private func switchChanged(_ sender: UISwitch) {
            let items: [(Bool, inout Bool)] = [
                (hideReadReceipts, &hideReadReceipts),
                (hideStoryViews, &hideStoryViews),
                (hideOnline, &hideOnline),
            ]
            guard sender.tag < items.count else { return }
            let newValue = sender.isOn
            switch sender.tag {
            case 0:
                hideReadReceipts = newValue
                FazeGramSettings.shared.hideReadReceipts = newValue
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideReadReceipts = newValue; return s }.start()
            case 1:
                hideStoryViews = newValue
                FazeGramSettings.shared.hideStoryViews = newValue
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideStoryViews = newValue; return s }.start()
            case 2:
                hideOnline = newValue
                FazeGramSettings.shared.hideOnline = newValue
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideOnline = newValue; return s }.start()
            default: break
            }
        }
    }

    return GhostModeController(context: context)
}
