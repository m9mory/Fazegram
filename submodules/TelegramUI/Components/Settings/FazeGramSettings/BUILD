load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "FazeGramSettings",
    module_name = "FazeGramSettings",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/Display",
        "//submodules/AsyncDisplayKit",
        "//submodules/AccountContext",
        "//submodules/TelegramPresentationData",
        "//submodules/Postbox",
        "//submodules/SSignalKit/SwiftSignalKit",
        "//submodules/TelegramCore",
        "//submodules/TelegramUIPreferences",
    ],
    visibility = [
        "//visibility:public",
    ],
)
