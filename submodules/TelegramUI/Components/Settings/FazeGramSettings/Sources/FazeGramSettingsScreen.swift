import Foundation
import UIKit
import Display
import ItemListUI
import SwiftSignalKit
import AccountContext
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences

// MARK: - Главный экран вкладки Fazegram

private enum FazeGramSettingsEntry: ItemListNodeEntry {
    case privacyHeader
    case ghostMode(Bool)

    var section: ItemListSectionId {
        switch self {
        case .privacyHeader, .ghostMode:
            return 0
        }
    }

    var stableId: Int {
        switch self {
        case .privacyHeader: return 0
        case .ghostMode: return 1
        }
    }

    static func < (lhs: FazeGramSettingsEntry, rhs: FazeGramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! FazeGramSettingsArguments
        switch self {
        case .privacyHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "ПРИВАТНОСТЬ",
                sectionId: self.section
            )
        case let .ghostMode(active):
            return ItemListDisclosureItem(
                presentationData: presentationData,
                title: "Режим призрака",
                label: active ? "Вкл" : "",
                sectionId: self.section,
                style: .blocks,
                action: {
                    arguments.openGhostMode()
                }
            )
        }
    }
}

private struct FazeGramSettingsArguments {
    let openGhostMode: () -> Void
}

public func fazeGramSettingsController(context: AccountContext) -> ViewController {
    var pushControllerImpl: ((ViewController) -> Void)?

    let arguments = FazeGramSettingsArguments(
        openGhostMode: {
            pushControllerImpl?(ghostModeSettingsController(context: context))
        }
    )

    let signal = fazeGramSettings(accountManager: context.sharedContext.accountManager)
    |> map { settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries: [FazeGramSettingsEntry] = [
            .privacyHeader,
            .ghostMode(settings.hideReadReceipts || settings.hideStoryViews || settings.hideOnline)
        ]

        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Fazegram"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )

        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks
        )

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] vc in
        controller?.push(vc)
    }
    return controller
}
