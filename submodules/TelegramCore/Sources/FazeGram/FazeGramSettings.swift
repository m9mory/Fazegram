import Foundation

public final class FazeGramSettings {
    public static let shared = FazeGramSettings()

    private let defaults = UserDefaults(suiteName: "group.ph.telegra.Telegraph") ?? UserDefaults.standard

    public var hideReadReceipts: Bool {
        get { defaults.bool(forKey: "fazegram_hideReadReceipts") }
        set { defaults.set(newValue, forKey: "fazegram_hideReadReceipts") }
    }

    public var hideStoryViews: Bool {
        get { defaults.bool(forKey: "fazegram_hideStoryViews") }
        set { defaults.set(newValue, forKey: "fazegram_hideStoryViews") }
    }

    public var hideOnline: Bool {
        get { defaults.bool(forKey: "fazegram_hideOnline") }
        set { defaults.set(newValue, forKey: "fazegram_hideOnline") }
    }
}
