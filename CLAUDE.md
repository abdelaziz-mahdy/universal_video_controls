# universal_video_controls — project guide

Melos monorepo with two published Flutter packages:

| Package | Native code | Notes |
|---|---|---|
| `universal_video_controls` | iOS + macOS (also Android/Linux/Windows/web) | The main controls package. Supports Swift Package Manager **and** CocoaPods. |
| `universal_video_controls_video_player` | none (pure Dart) | `video_player` adapter for `universal_video_controls`. |

Both publish from this repo (`abdelaziz-mahdy/universal_video_controls`) to pub.dev under the `zcreations.info` publisher.

## Swift Package Manager (universal_video_controls)

The iOS/macOS plugin supports SPM following Flutter's official plugin-author
migration, while keeping CocoaPods working. Layout per platform:

```
<ios|macos>/
├── universal_video_controls/
│   ├── Package.swift                 # swift-tools 5.9; depends on FlutterFramework
│   └── Sources/universal_video_controls/
│       ├── UniversalVideoControlsPlugin.swift
│       └── PrivacyInfo.xcprivacy     # empty manifest; resource line commented
└── universal_video_controls.podspec  # kept for CocoaPods; source_files -> Sources/
```

Key constraints (set because the modern SPM `FlutterFramework` dependency
requires them):
- `pubspec.yaml`: `sdk: ^3.11.0`, `flutter: ">=3.41.0"`.
- iOS deployment target 13.0 (Flutter dropped iOS 12); macOS `Package.swift` 10.15, podspec 10.11.
- Keep BOTH `Package.swift` and `.podspec` in sync — CocoaPods support is still required.

When regenerating native scaffolding, the source of truth is what
`flutter create --template=plugin` produces on the current stable Flutter; mirror it.

## Releasing (automated, OIDC — no secrets)

Each package is released independently via a **package-prefixed git tag**.
pub.dev automated publishing is configured per package (Admin → automated
publishing) with:
- Repository: `abdelaziz-mahdy/universal_video_controls`
- Tag pattern: `universal_video_controls-v{{version}}`
  (and `universal_video_controls_video_player-v{{version}}`)

Steps to cut a release:
1. Bump `version:` in the package's `pubspec.yaml` and add a `CHANGELOG.md` entry.
2. Merge to `main` (branch + PR; never commit releases straight to main).
3. Create the tag/release on `main`:
   - `gh release create universal_video_controls-v<x.y.z> --target main ...`
   - `gh release create universal_video_controls_video_player-v<x.y.z> --target main ...`
4. The matching workflow publishes automatically (verify the run is green and
   that pub.dev shows the new version).

The tag version MUST equal the package's `pubspec.yaml` version — pub.dev
rejects a mismatch.

### Publish workflows (`.github/workflows/publish-*.yml`)

One file per package. Each triggers on its prefixed tag and delegates to
pub.dev's official reusable workflow:

```yaml
jobs:
  publish:
    permissions:
      id-token: write
    uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1
    with:
      working-directory: <package-dir>
```

**Do NOT replace this with a custom job that runs `flutter pub publish`.** A
Flutter-only setup never provisions the OIDC token, so `pub publish` falls back
to interactive Google OAuth and the CI run hangs forever
(flutter/flutter#138593). The reusable workflow works because it runs
`dart-lang/setup-dart` (provisions OIDC) **plus** a Flutter SDK (so `dart pub
publish` can resolve Flutter packages).

## CI (`.github/workflows/deploy.yml`)

On every push/PR to `main`, builds the example app for web, Android, iOS,
macOS, Windows, Linux (build-only, no tests). On `main` it also deploys the web
example to GitHub Pages.

- CI does **not** enable Swift Package Manager, so its iOS/macOS jobs validate
  the **CocoaPods** path. The SPM path is verified manually
  (`flutter config --enable-swift-package-manager` + build the example).
- Uses unpinned `channel: stable`; watch for toolchain rot (e.g. the removed
  `--web-renderer` flag, and bundled googletest's CMake minimum version on Windows).

## Conventions

- Append-only git history: new commits over amend; regular push over force-push.
- Release tags are package-prefixed and version-`v`-prefixed
  (`<package>-v<version>`).
- `pub publish` blocks on `dart analyze` **warnings** (not info-level lints); keep
  the package `lib/` warning-free before releasing.
