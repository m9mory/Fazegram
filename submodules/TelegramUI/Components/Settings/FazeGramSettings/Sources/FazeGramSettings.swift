import Foundation
import Postbox
import SwiftSignalKit
import TelegramCore
import TelegramUIPreferences

public struct FazeGramSettingsData: Codable, Equatable {
    public var hideReadReceipts: Bool
    public var hideStoryViews: Bool
    public var hideOnline: Bool

    public static var defaultValue: FazeGramSettingsData {
        return FazeGramSettingsData(
            hideReadReceipts: false,
            hideStoryViews: false,
            hideOnline: false
        )
    }

    public init(hideReadReceipts: Bool, hideStoryViews: Bool, hideOnline: Bool) {
        self.hideReadReceipts = hideReadReceipts
        self.hideStoryViews = hideStoryViews
        self.hideOnline = hideOnline
    }
}

public func fazeGramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<FazeGramSettingsData, NoError> {
    return accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.fazeGramSettings])
    |> map { sharedData -> FazeGramSettingsData in
        return sharedData.entries[ApplicationSpecificSharedDataKeys.fazeGramSettings]?.get(FazeGramSettingsData.self) ?? .defaultValue
    }
}

public func updateFazeGramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (FazeGramSettingsData) -> FazeGramSettingsData) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction in
        let settings = transaction.getSharedData(ApplicationSpecificSharedDataKeys.fazeGramSettings)?.get(FazeGramSettingsData.self) ?? .defaultValue
        transaction.updateSharedData(ApplicationSpecificSharedDataKeys.fazeGramSettings) { _ in
            return PreferencesEntry(f(settings))
        }
    }
}
