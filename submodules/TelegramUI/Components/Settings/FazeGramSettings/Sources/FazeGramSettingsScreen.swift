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

public func fazeGramSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }

    var pushImpl: ((ViewController) -> Void)?

    let arguments = FazeGramSettingsArguments(
        openGhostMode: {
            pushImpl?(ghostModeSettingsController(context: context))
        },
        openChannel: {
            context.sharedContext.applicationBindings.openUrl("https://t.me/Fazegram")
        },
        openChat: {
            context.sharedContext.applicationBindings.openUrl("https://t.me/fazegramchat")
        }
    )

    let signal = fazeGramSettings(accountManager: context.sharedContext.accountManager)
    |> map { settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let ghostActive = settings.hideReadReceipts || settings.hideStoryViews || settings.hideOnline

        let entries: [FazeGramScreenEntry] = [
            .privacyHeader,
            .ghostMode(ghostActive),
            .otherHeader,
            .avatarLimit,
            .avatarLimitDesc,
            .linksSeparator,
            .ourChannel,
            .ourChat,
            .versionFooter,
        ]

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
    pushImpl = { [weak controller] vc in
        controller?.push(vc)
    }
    return controller
}

private struct FazeGramSettingsArguments {
    let openGhostMode: () -> Void
    let openChannel: () -> Void
    let openChat: () -> Void
}

private enum FazeGramScreenEntry: ItemListNodeEntry {
    case privacyHeader
    case ghostMode(Bool)
    case otherHeader
    case avatarLimit
    case avatarLimitDesc
    case linksSeparator
    case ourChannel
    case ourChat
    case versionFooter

    var section: ItemListSectionId {
        switch self {
        case .privacyHeader, .ghostMode:
            return 0
        case .otherHeader, .avatarLimit:
            return 1
        case .avatarLimitDesc:
            return 2
        case .linksSeparator, .ourChannel, .ourChat:
            return 3
        case .versionFooter:
            return 4
        }
    }

    var stableId: Int {
        switch self {
        case .privacyHeader: return 0
        case .ghostMode: return 1
        case .otherHeader: return 2
        case .avatarLimit: return 3
        case .avatarLimitDesc: return 4
        case .linksSeparator: return 5
        case .ourChannel: return 6
        case .ourChat: return 7
        case .versionFooter: return 8
        }
    }

    var sortIndex: Int { return self.stableId }

    static func < (lhs: FazeGramScreenEntry, rhs: FazeGramScreenEntry) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! FazeGramSettingsArguments
        switch self {
        case .privacyHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "Приватность",
                sectionId: self.section
            )
        case let .ghostMode(active):
            return ItemListDisclosureItem(
                presentationData: presentationData,
                title: "Режим призрака",
                label: active ? "Вкл" : "",
                sectionId: self.section,
                style: .blocks,
                action: { arguments.openGhostMode() }
            )
        case .otherHeader:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "Прочее",
                sectionId: self.section
            )
        case .avatarLimit:
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: "Выключить лимит по показываемым аватаркам",
                value: FazeGramSettings.shared.avatarLimitUnlocked,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    FazeGramSettings.shared.avatarLimitUnlocked = value
                }
            )
        case .avatarLimitDesc:
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain("Лимит по показываемым аватаркам в профилях на iOS — 100, а с этой опцией — 10.000"),
                sectionId: self.section
            )
        case .linksSeparator:
            return ItemListSectionHeaderItem(
                presentationData: presentationData,
                text: "",
                sectionId: self.section
            )
        case .ourChannel:
            return ItemListDisclosureItem(
                presentationData: presentationData,
                title: "Наш канал",
                label: "",
                sectionId: self.section,
                style: .blocks,
                action: { arguments.openChannel() }
            )
        case .ourChat:
            return ItemListDisclosureItem(
                presentationData: presentationData,
                title: "Наш чат",
                label: "",
                sectionId: self.section,
                style: .blocks,
                action: { arguments.openChat() }
            )
        case .versionFooter:
            let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "12.8"
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain("Fazegram \(appVersion)"),
                sectionId: self.section
            )
        }
    }
}
