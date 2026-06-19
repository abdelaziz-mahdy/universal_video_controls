# Swift Package Manager migration — `universal_video_controls`

**Date:** 2026-06-19
**Author:** Abdelaziz Mahdy (with Claude Code)
**Status:** Approved design, pending implementation

## Goal

Add Swift Package Manager (SPM) support to the `universal_video_controls` plugin
for iOS and macOS, following Flutter's official plugin-author migration, while
keeping CocoaPods working for consumers that have not enabled SPM. Deliver the
change as a single branch + pull request for review.

## Background

The repository is a Melos monorepo with two packages:

- `universal_video_controls` — **has** native iOS + macOS code (a single
  `UniversalVideoControlsPlugin.swift` per platform, boilerplate
  `getPlatformVersion` method channel from `flutter create --template=plugin`).
- `universal_video_controls_video_player` — pure Dart, **no** native code.

SPM migration only applies to packages with native iOS/macOS code, so the work
is scoped to `universal_video_controls` only.

Local toolchain: **Flutter 3.44.2 / Dart 3.12.2** (stable). On this version,
`flutter create --template=plugin` generates the **modern SPM layout** that
depends on a `FlutterFramework` Swift package via a relative path. This design
mirrors that scaffold output exactly (verified by scaffolding a throwaway plugin
with this toolchain).

## Decisions

1. **Scope:** migrate `universal_video_controls` only. No changes to the
   pure-Dart package or the Melos root.
2. **Approach:** modern `FlutterFramework` SPM mechanism, exactly as Flutter
   3.44 generates it (swift-tools 5.9, `FlutterFramework` path dependency).
3. **CocoaPods:** keep both `.podspec` files for backward compatibility; update
   their `source_files` to point at the new `Sources/` layout. (Flutter requires
   plugins to support both SPM and CocoaPods; the CocoaPods registry goes
   read-only on 2026-12-02.)
4. **Minimum SDK floors:** raise to `flutter: ">=3.41.0"` / `sdk: ^3.11.0` and
   iOS deployment `12.0 → 13.0`. The `FlutterFramework` SPM package only exists
   on Flutter ≥ 3.41; shipping the Package.swift without raising the floor would
   break consumers on older Flutter that enable SPM. Flutter 3.44 no longer
   supports iOS 12 regardless.

## Target structure

```
universal_video_controls/
├── ios/
│   ├── .gitignore                                  (add .build/, .swiftpm/)
│   ├── universal_video_controls/
│   │   ├── Package.swift                            ← new
│   │   └── Sources/universal_video_controls/
│   │       ├── UniversalVideoControlsPlugin.swift   ← moved from ios/Classes/
│   │       └── PrivacyInfo.xcprivacy                ← new (empty manifest)
│   └── universal_video_controls.podspec            ← source_files updated
└── macos/
    ├── universal_video_controls/
    │   ├── Package.swift                            ← new
    │   └── Sources/universal_video_controls/
    │       ├── UniversalVideoControlsPlugin.swift   ← moved from macos/Classes/
    │       └── PrivacyInfo.xcprivacy                ← new (empty manifest)
    ├── Flutter/GeneratedPluginRegistrant.swift     ← unchanged (left as-is)
    └── universal_video_controls.podspec            ← source_files updated
```

Notes:
- `ios/Classes/` and `macos/Classes/` are deleted after their `.swift` files
  move. `ios/Assets/.gitkeep` is removed with the now-empty `Assets` dir.
- `macos/Flutter/GeneratedPluginRegistrant.swift` is left untouched — it is
  generated and out of scope for this migration.

## File contents

### iOS `Package.swift`

```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "universal_video_controls",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "universal-video-controls", targets: ["universal_video_controls"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "universal_video_controls",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
```

### macOS `Package.swift`

Identical to iOS except the platform line:

```swift
    platforms: [
        .macOS("10.15")
    ],
```

(The library name still uses the hyphenated `universal-video-controls`, target
and package name keep underscores. macOS Package.swift uses `10.15` to satisfy
`FlutterFramework`; the macOS podspec stays at `10.11`, matching the scaffold.)

### Podspec changes

Both podspecs: change `source_files` from `'Classes/**/*'` to
`'universal_video_controls/Sources/universal_video_controls/**/*'`. iOS podspec
also bumps `s.platform = :ios, '12.0'` → `:ios, '13.0'`. Everything else in the
podspecs (dependencies, xcconfig, swift_version) is unchanged. A commented
`s.resource_bundles` privacy line is added to mirror the scaffold.

### `PrivacyInfo.xcprivacy`

Empty manifest (no tracking, no collected data, no accessed APIs) — the plugin
only calls `getPlatformVersion`, which uses no required-reason APIs. File is
included but the `.process("PrivacyInfo.xcprivacy")` resource line stays
commented in both `Package.swift` and podspec, matching the scaffold default.

### pubspec.yaml

```yaml
environment:
  sdk: ^3.11.0
  flutter: ">=3.41.0"
```

(Was `sdk: '>=3.0.0 <4.0.0'`, `flutter: ">=1.17.0"`.)

### Version

The SDK-floor bump is a breaking change under pub semver. Recommend bumping the
package version to **2.0.0** and adding a CHANGELOG entry, but the final version
number is the author's call at release time. The PR will propose a version +
CHANGELOG entry for review.

### .gitignore

Add `.build/` and `.swiftpm/` to the plugin's `ios/.gitignore` (and create a
`macos/.gitignore` with the same SPM entries, since none exists today) to avoid
committing SPM build artifacts.

## Native code

The Swift source files move verbatim — no behavior change. They are valid as-is
under SPM (the plugin classes `import Flutter` / `import FlutterMacOS`, which the
`FlutterFramework` dependency provides).

## Verification

1. `flutter pub get` + `dart analyze` at the workspace (Melos) level — clean.
2. Validate each `Package.swift` parses where the toolchain allows
   (`swift package dump-package` may fail to resolve the relative
   `FlutterFramework` path outside a Flutter build context; a parse/describe
   check is best-effort).
3. CocoaPods path: confirm podspec `source_files` resolve to the moved files.
   `pod lib lint` is best-effort (it requires the Flutter pod in scope).
4. Build the example app both ways (manual, documented in the PR):
   - SPM: `flutter config --enable-swift-package-manager && cd universal_video_controls/example && flutter build ios --no-codesign` (and `macos`).
   - CocoaPods: `flutter config --no-enable-swift-package-manager && flutter build ios --no-codesign`.

   Note: `flutter config --enable-swift-package-manager` was enabled globally on
   this machine during research; it is a reversible opt-in flag.

## Deliverable

A single feature branch (e.g. `feat/swift-package-manager`) and one pull request
against `main` containing the above changes, with a description summarizing the
migration, the floor bumps, and the verification performed, for the author's
review.

## Out of scope

- Any change to `universal_video_controls_video_player` or the Melos root.
- Removing/altering the boilerplate `getPlatformVersion` native code.
- Touching `macos/Flutter/GeneratedPluginRegistrant.swift`.
- Android / Linux / Windows / web plugin platforms.
