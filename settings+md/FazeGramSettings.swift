import Foundation
import Postbox
import SwiftSignalKit

// MARK: - Модель настроек

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

extension FazeGramSettingsData: PreferencesEntry {
    public func isEqual(to: PreferencesEntry) -> Bool {
        guard let other = to as? FazeGramSettingsData else { return false }
        return self == other
    }
}

// MARK: - Ключ в AccountManager

public func fazeGramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<FazeGramSettingsData, NoError> {
    return accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.fazeGramSettings])
    |> map { sharedData -> FazeGramSettingsData in
        return sharedData.entries[ApplicationSpecificSharedDataKeys.fazeGramSettings]?.get(FazeGramSettingsData.self) ?? .defaultValue
    }
}

public func updateFazeGramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (FazeGramSettingsData) -> FazeGramSettingsData) -> Signal<Void, NoError> {
    return accountManager.updateSharedData(key: ApplicationSpecificSharedDataKeys.fazeGramSettings, { current in
        let settings = current?.get(FazeGramSettingsData.self) ?? .defaultValue
        return PreferencesEntry(f(settings))
    })
}
