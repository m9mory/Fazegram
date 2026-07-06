# Fazegram — Ghost Mode Patches

Форк Telegram-iOS. Нужно реализовать три патча для Ghost Mode.

## 1. Скрыть прочтение (Hide Read Receipts)

**Что нужно:** При открытии чата Telegram отправляет на сервер запрос `messages.readHistory` — нужно заблокировать этот вызов если Ghost Mode включён.

**Где искать:**
```
submodules/TelegramCore/Sources/TelegramEngine/Messages/MarkAllChatsAsRead.swift
```
Там есть вызовы:
- `Api.functions.messages.readHistory(peer: inputPeer, maxId: ...)`
- `Api.functions.channels.readHistory(channel: inputChannel, maxId: ...)`

Нужно добавить проверку перед каждым `network.request(Api.functions.messages.readHistory(...))` и `network.request(Api.functions.channels.readHistory(...))`:
```swift
guard !FazeGramSettings.shared.hideReadReceipts else { return .complete() }
```

---

## 2. Скрыть просмотр сторис (Hide Story Views)

**Что нужно:** При просмотре сторис Telegram отправляет `stories.incrementStoryViews` — нужно заблокировать.

**Где искать:**
```
submodules/TelegramCore/Sources/TelegramEngine/Peers/
```
Поиск по файлам: `incrementStoryViews` или `markStoryAsSeen`

Нужно добавить проверку перед вызовом API:
```swift
guard !FazeGramSettings.shared.hideStoryViews else { return .complete() }
```

---

## 3. Скрыть онлайн (Hide Online Status)

**Что нужно:** Telegram периодически отправляет `account.updateStatus(offline: false)` — нужно всегда отправлять `offline: true` если Ghost Mode включён.

**Где искать:**
```
submodules/TelegramCore/Sources/TelegramEngine/AccountData/UpdateAccountPresence.swift
```
или поиск по: `account.updateStatus`

Нужно заменить:
```swift
Api.functions.account.updateStatus(offline: .boolFalse)
```
на:
```swift
Api.functions.account.updateStatus(offline: FazeGramSettings.shared.hideOnline ? .boolTrue : .boolFalse)
```

---

## Хранение настроек

Создать файл `FazeGramSettings.swift`:

```swift
import Foundation

public final class FazeGramSettings {
    public static let shared = FazeGramSettings()
    
    private let defaults = UserDefaults(suiteName: "FazeGramSettings")!
    
    public var hideReadReceipts: Bool {
        get { defaults.bool(forKey: "hideReadReceipts") }
        set { defaults.set(newValue, forKey: "hideReadReceipts") }
    }
    
    public var hideStoryViews: Bool {
        get { defaults.bool(forKey: "hideStoryViews") }
        set { defaults.set(newValue, forKey: "hideStoryViews") }
    }
    
    public var hideOnline: Bool {
        get { defaults.bool(forKey: "hideOnline") }
        set { defaults.set(newValue, forKey: "hideOnline") }
    }
}
```

---

## Вкладка в настройках

**Где встраивать:**
```
submodules/TelegramUI/Sources/PeerInfo/PeerInfoScreen.swift
```
или поиск по: `editingItems` / `settingsItems`

Нужно добавить строку "Fazegram" между карточкой профиля и "Мой профиль", которая открывает `FazeGramSettingsScreen`.
