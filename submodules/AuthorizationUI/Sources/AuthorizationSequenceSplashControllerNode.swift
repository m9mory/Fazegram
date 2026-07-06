import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData

final class AuthorizationSequenceSplashControllerNode: ASDisplayNode {
    private let iconNode: ASImageNode
    private let titleNode: ImmediateTextNode

    init(theme: PresentationTheme) {
        self.iconNode = ASImageNode()
        self.iconNode.displaysAsynchronously = false
        self.iconNode.contentMode = .scaleAspectFill

        self.titleNode = ImmediateTextNode()
        self.titleNode.displaysAsynchronously = false
        self.titleNode.textAlignment = .center
        self.titleNode.maximumNumberOfLines = 2

        super.init()

        self.setViewBlock({
            return UITracingLayerView()
        })

        self.backgroundColor = theme.list.plainBackgroundColor
        self.view.disablesInteractiveTransitionGestureRecognizer = true

        self.addSubnode(self.iconNode)
        self.addSubnode(self.titleNode)

        // Use app icon, fallback to default
        if let appIcon = UIImage(named: "AppIconLLC") ?? UIImage(named: "AppIcon60x60") {
            self.iconNode.image = appIcon
        }

        // Get app name from bundle
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "Fazegram"

        let title = "\(appName) is the world's\nfastest messaging app."
        self.titleNode.attributedText = NSAttributedString(
            string: title,
            font: Font.light(20.0),
            textColor: theme.list.itemPrimaryTextColor
        )
    }

    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        let iconSize: CGFloat = 100.0
        let iconCornerRadius: CGFloat = iconSize / 2.0
        let spacing: CGFloat = 24.0

        let titleSize = self.titleNode.updateLayout(CGSize(width: layout.size.width - 80.0, height: CGFloat.greatestFiniteMagnitude))

        let totalHeight = iconSize + spacing + titleSize.height
        let startY = (layout.size.height - totalHeight) / 2.0

        let iconFrame = CGRect(
            x: (layout.size.width - iconSize) / 2.0,
            y: startY,
            width: iconSize,
            height: iconSize
        )

        transition.updateFrame(node: self.iconNode, frame: iconFrame)
        self.iconNode.cornerRadius = iconCornerRadius
        self.iconNode.clipsToBounds = true

        let titleFrame = CGRect(
            x: (layout.size.width - titleSize.width) / 2.0,
            y: iconFrame.maxY + spacing,
            width: titleSize.width,
            height: titleSize.height
        )
        transition.updateFrame(node: self.titleNode, frame: titleFrame)
    }
}
