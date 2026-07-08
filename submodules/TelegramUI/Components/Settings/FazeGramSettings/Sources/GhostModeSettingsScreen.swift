import Foundation
import UIKit
import Display
import ItemListUI
import SwiftSignalKit
import AccountContext
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import PresentationDataUtils

public func ghostModeSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }

    let signal = fazeGramSettings(accountManager: context.sharedContext.accountManager)
    |> map { settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let arguments = GhostModeArguments(
            toggleHideReadReceipts: { value in
                FazeGramSettings.shared.hideReadReceipts = value
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideReadReceipts = value; return s }.start()
            },
            toggleHideStoryViews: { value in
                FazeGramSettings.shared.hideStoryViews = value
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideStoryViews = value; return s }.start()
            },
            toggleHideOnline: { value in
                FazeGramSettings.shared.hideOnline = value
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideOnline = value; return s }.start()
            },
            toggleHideTyping: { value in
                FazeGramSettings.shared.hideTyping = value
                let _ = updateFazeGramSettings(accountManager: context.sharedContext.accountManager) { s in var s = s; s.hideTyping = value; return s }.start()
            }
        )

        let entries: [GhostModeEntry] = [
            .hideReadReceipts(settings.hideReadReceipts),
            .hideStoryViews(settings.hideStoryViews),
            .hideOnline(settings.hideOnline),
            .hideTyping(settings.hideTyping),
        ]

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

private struct GhostModeArguments {
    let toggleHideReadReceipts: (Bool) -> Void
    let toggleHideStoryViews: (Bool) -> Void
    let toggleHideOnline: (Bool) -> Void
    let toggleHideTyping: (Bool) -> Void
}

private enum GhostModeEntry: ItemListNodeEntry {
    case hideReadReceipts(Bool)
    case hideStoryViews(Bool)
    case hideOnline(Bool)
    case hideTyping(Bool)

    var section: ItemListSectionId { return 0 }

    var stableId: Int {
        switch self {
        case .hideReadReceipts: return 0
        case .hideStoryViews: return 1
        case .hideOnline: return 2
        case .hideTyping: return 3
        }
    }

    var sortIndex: Int { return self.stableId }

    static func < (lhs: GhostModeEntry, rhs: GhostModeEntry) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
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
                updated: { arguments.toggleHideReadReceipts($0) }
            )
        case let .hideStoryViews(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть просмотр сторис",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { arguments.toggleHideStoryViews($0) }
            )
        case let .hideOnline(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть онлайн",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { arguments.toggleHideOnline($0) }
            )
        case let .hideTyping(value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Скрыть печатание",
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { arguments.toggleHideTyping($0) }
            )
        }
    }
}
