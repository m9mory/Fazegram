# Инструкция для Deepseek — Fazegram

## Шаг 1 — Создай папку и закинь файлы

Создай папку:
```
submodules/TelegramUI/Components/Settings/FazeGramSettings/Sources/
```

Закинь туда три файла:
- `FazeGramSettings.swift`
- `FazeGramSettingsScreen.swift`
- `GhostModeSettingsScreen.swift`

---

## Шаг 2 — Добавь ключ для хранения настроек

Открой файл:
```
submodules/TelegramUI/Sources/ApplicationSpecificSharedDataKeys.swift
```

Найди список ключей и добавь:
```swift
public static let fazeGramSettings = ApplicationSpecificSharedDataKey(rawValue: 200)
```
(число должно быть уникальным, проверь что 200 не занято)

---

## Шаг 3 — Встрой вкладку в настройки

Открой файл:
```
submodules/TelegramUI/Sources/PeerInfo/PeerInfoScreen.swift
```

Поищи по тексту `editingItems` или `myProfile` или `savedMessages` — там где список пунктов настроек.

Нужно добавить строку Fazegram МЕЖДУ карточкой профиля и пунктом "Мой профиль". Добавь примерно так:

```swift
// Fazegram
entries.append(.fazeGram)
```

И в switch где обрабатываются нажатия добавь:
```swift
case .fazeGram:
    pushControllerImpl?(fazeGramSettingsController(context: context))
```

---

## Шаг 4 — Добавь BUILD файл

Создай файл:
```
submodules/TelegramUI/Components/Settings/FazeGramSettings/BUILD
```

Содержимое (скопируй структуру из соседней папки например PrivacyAndSecurityUI/BUILD и поменяй имена):
```python
load("@build_configuration//:variables.bzl", ...)

swift_library(
    name = "FazeGramSettings",
    srcs = glob(["Sources/**/*.swift"]),
    deps = [
        "//submodules/Display",
        "//submodules/AccountContext",
        "//submodules/TelegramPresentationData",
        "//submodules/ItemListUI",
        "//submodules/Postbox",
        "//submodules/SwiftSignalKit",
    ],
)
```

---

## Шаг 5 — Зарегистрируй модуль

Открой:
```
submodules/TelegramUI/BUILD
```

Найди список deps и добавь:
```python
"//submodules/TelegramUI/Components/Settings/FazeGramSettings",
```

---

## Шаг 6 — Ghost Mode патчи

### Скрыть прочтение
Файл: `submodules/TelegramCore/Sources/TelegramEngine/Messages/MarkAllChatsAsRead.swift`

Перед каждым вызовом `network.request(Api.functions.messages.readHistory(...))` добавь:
```swift
if FazeGramSettings.shared.hideReadReceipts { return .complete() }
```

### Скрыть онлайн
Поищи по проекту: `account.updateStatus`

Найди вызов и замени `offline: .boolFalse` на:
```swift
offline: FazeGramSettings.shared.hideOnline ? .boolTrue : .boolFalse
```

### Скрыть просмотр сторис
Поищи по проекту: `incrementStoryViews` или `markStoryAsSeen`

Перед вызовом API добавь:
```swift
if FazeGramSettings.shared.hideStoryViews { return .complete() }
```
