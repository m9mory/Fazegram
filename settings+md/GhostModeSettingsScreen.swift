import Foundation
import UIKit
import Display
import AccountContext
import TelegramPresentationData

// MARK: - Экран Ghost Mode

private enum GhostModeEntry: ItemListNodeEntry {
    case hideReadReceipts(Bool)
    case hideStoryViews(Bool)
    case hideOnline(Bool)

    var section: ItemListSectionId { return 0 }

    var stableId: Int {
        switch self {
        case .hideReadReceipts: return 0
        case .hideStoryViews: return 1
        case .hideOnline: return 2
        }
    }

    static func < (lhs: GhostModeEntry, rhs: GhostModeEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! GhostModeArguments
        switch self {
        case let .hideReadReceipts(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть прочтение",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { newValue in
                    arguments.toggleHideReadReceipts(newValue)
                }
            )
        case let .hideStoryViews(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть просмотр сторис",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { newValue in
                    arguments.toggleHideStoryViews(newValue)
                }
            )
        case let .hideOnline(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть онлайн",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { newValue in
                    arguments.toggleHideOnline(newValue)
                }
            )
        }
    }
}

private struct GhostModeArguments {
    let toggleHideReadReceipts: (Bool) -> Void
    let toggleHideStoryViews: (Bool) -> Void
    let toggleHideOnline: (Bool) -> Void
}

public func ghostModeSettingsController(context: AccountContext) -> ViewController {
    let arguments = GhostModeArguments(
        toggleHideReadReceipts: { value in
            let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager, { settings in
                var s = settings
                s.hideReadReceipts = value
                return s
            }).start()
        },
        toggleHideStoryViews: { value in
            let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager, { settings in
                var s = settings
                s.hideStoryViews = value
                return s
            }).start()
        },
        toggleHideOnline: { value in
            let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager, { settings in
                var s = settings
                s.hideOnline = value
                return s
            }).start()
        }
    )

    let signal = fazeGramSettings(accountManager: context.sharedContext.accountManager)
    |> map { settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries: [GhostModeEntry] = [
            .hideReadReceipts(settings.hideReadReceipts),
            .hideStoryViews(settings.hideStoryViews),
            .hideOnline(settings.hideOnline)
        ]

        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Режим призрака"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: "Fazegram")
        )

        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks
        )

        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
