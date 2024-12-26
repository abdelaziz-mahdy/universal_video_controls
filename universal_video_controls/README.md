# universal_video_controls

## Overview

The `universal_video_controls` package provides a comprehensive solution for video controls that can be universally applied to various video players. This package is a port and generalization of the [media_kit](https://pub.dev/packages/media_kit) controls, designed to create an abstraction that allows these controls to work with any video player backend, provided that the backend's interface is compatible with the `AbstractPlayer` class.

## Images

| Desktop                                                                                                                                                            | Mobile                                                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![Desktop with Controls](https://github.com/abdelaziz-mahdy/universal_video_controls/blob/main/universal_video_controls/images/desktop_with_controls.png?raw=true) | ![Mobile with Controls](https://github.com/abdelaziz-mahdy/universal_video_controls/blob/main/universal_video_controls/images/mobile_with_controls.png?raw=true) |

## Examples

Examples can be found at:

- [Universal Video Controls Examples](https://github.com/abdelaziz-mahdy/universal_video_controls/tree/main/universal_video_controls/example)
- [Example Demo](https://abdelaziz-mahdy.github.io/universal_video_controls/)

## Getting Started

This section will guide you through the steps to get started with the `universal_video_controls` package.

### Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  universal_video_controls: ^1.0.10
  universal_video_controls_video_player: ^1.0.1
  video_player: ^2.2.5
```

Then run `flutter pub get` to install the packages.

### Usage

To use the `universal_video_controls` package, you need to integrate it with a video player backend that implements the `AbstractPlayer` interface. Here is a minimal example demonstrating how to set up and use the `universal_video_controls` with the `video_player` package.

#### Example: Single Player Single Video

```dart
import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SinglePlayerSingleVideoScreen(),
    );
  }
}

class SinglePlayerSingleVideoScreen extends StatefulWidget {
  @override
  State<SinglePlayerSingleVideoScreen> createState() => _SinglePlayerSingleVideoScreenState();
}

class _SinglePlayerSingleVideoScreenState extends State<SinglePlayerSingleVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer('https://www.example.com/video.mp4');
  }

  void _initializeVideoPlayer(String source) async {
    _controller = VideoPlayerController.network(source);
    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
    _controller.play();
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint(_controller.value.errorDescription);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoControls(
                  player: VideoPlayerControlsWrapper(_controller),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
```

#### Select existing video controls

Modify the `controls` argument. For advanced theming of existing video controls, see [theming & modifying video controls](#theming-&-modifying-video-controls) section.

```dart
Scaffold(
  body: VideoControls(
    controller: controller,
    // Select [MaterialVideoControls].
    controls: MaterialVideoControls,
  ),
);
```

```dart
Scaffold(
  body: VideoControls(
    controller: controller,
    // Select [CupertinoVideoControls].
    controls: CupertinoVideoControls,
  ),
);
```

#### Build custom video controls

Pass custom builder `Widget Function(BuildContext, VideoController)` as `controls` argument.

```dart
Scaffold(
  body: VideoControls(
    controller: controller,
    // Provide custom builder for controls.
    controls: (state) {
      return Center(
        child: IconButton(
          onPressed: () {
            state.widget.controller.player.playOrPause();
          },
          icon: StreamBuilder(
            stream: state.widget.controller.player.stream.playing,
            builder: (context, playing) => Icon(
              playing.data == true ? Icons.pause : Icons.play_arrow,
            ),
          ),
          // It's not necessary to use [StreamBuilder] or to use [Player] & [VideoController] from [state].
          // [StreamSubscription]s can be made inside [initState] of this widget.
        ),
      );
    },
  ),
);
```

#### Use & modify video controls

##### `AdaptiveVideoControls`

- Selects [`MaterialVideoControls`](#materialvideocontrols), [`CupertinoVideoControls`](#cupertinovideocontrols) etc. based on platform.
- Theming:
  - Theme the specific controls according to sections below.

##### `MaterialVideoControls`

- [Material Design](https://material.io/) video controls.
- Theming:
  - Use `MaterialVideoControlsTheme` widget.
  - `VideoControls` widget(s) in the `child` tree will follow the specified theme:

```dart
// Wrap [VideoControls] widget with [MaterialVideoControlsTheme].
MaterialVideoControlsTheme(
  normal: MaterialVideoControlsThemeData(
    // Modify theme options:
    buttonBarButtonSize: 24.0,
    buttonBarButtonColor: Colors.white,
    // Modify top button bar:
    topButtonBar: [
      const Spacer(),
      MaterialDesktopCustomButton(
        onPressed: () {
          debugPrint('Custom "Settings" button pressed.');
        },
        icon: const Icon(Icons.settings),
      ),
    ],
  ),
  fullscreen: const MaterialVideoControlsThemeData(
    // Modify theme options:
    displaySeekBar: false,
  ),
  child: Scaffold(
    body: VideoControls(
      controller: controller,
    ),
  ),
);
```

- Related widgets (may be used in `primaryButtonBar`, `topButtonBar` & `bottomButtonBar`):
  - `MaterialPlayOrPauseButton`
  - `MaterialSkipNextButton`
  - `MaterialSkipPreviousButton`
  - `MaterialFullscreenButton`
  - `MaterialCustomButton`
  - `MaterialPositionIndicator`

##### `MaterialDesktopVideoControls`

- [Material Design](https://material.io/) video controls for desktop.
- Theming:
  - Use `MaterialDesktopVideoControlsTheme` widget.
  - `VideoControls` widget(s) in the `child` tree will follow the specified theme:

```dart
// Wrap [VideoControls] widget with [MaterialDesktopVideoControlsTheme].
MaterialDesktopVideoControlsTheme(
  normal: MaterialDesktopVideoControlsThemeData(
    // Modify theme options:
    seekBarThumbColor: Colors.blue,
    seekBarPositionColor: Colors.blue,
    toggleFullscreenOnDoublePress: false,
    // Modify top button bar:
    topButtonBar: [
      const Spacer(),
      MaterialDesktopCustomButton(
        onPressed: () {
          debugPrint('Custom "Settings" button pressed.');
        },
        icon: const Icon(Icons.settings),
      ),
    ],
    // Modify bottom button bar:
    bottomButtonBar: const [
      Spacer(),
      MaterialDesktopPlayOrPauseButton(),
      Spacer(),
    ],
  ),
  fullscreen: const MaterialDesktopVideoControlsThemeData(),
  child: Scaffold(
    body: VideoControls(
      controller: controller,
    ),
  ),
);
```

- Related widgets (may be used in `primaryButtonBar`, `topButtonBar` & `bottomButtonBar`):
  - `MaterialDesktopPlayOrPauseButton`
  - `MaterialDesktopFullscreenButton`
  - `MaterialDesktopCustomButton`
  - `MaterialDesktopVolumeButton`
  - `MaterialDesktopPositionIndicator`
- Keyboard shortcuts may be modified using `keyboardShortcuts` argument. Default ones are listed below:

| Shortcut                | Action                |
| ----------------------- | --------------------- |
| Media Play Button       | Play                  |
| Media Pause Button      | Pause                 |
| Media Play/Pause Button | Play/Pause            |
| Space                   | Play/Pause            |
| J                       | Seek 10s Behind       |
| I                       | Seek 10s Ahead        |
| Arrow Left              | Seek 5s Behind        |
| Arrow Right             | Seek 5s Ahead         |
| Arrow Up                | Increase Volume 5%    |
| Arrow Down              | Decrease Volume 5%    |
| F                       | Enter/Exit Fullscreen |
| Escape                  | Exit Fullscreen       |

##### `CupertinoVideoControls`

- [iOS-style](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios) video controls.
- Theming:
  - Use `CupertinoVideoControlsTheme` widget.
  - `VideoControls` widget(s) in the `child` tree will follow the specified theme:

```dart
// Wrap [VideoControls] widget with [CupertinoVideoControlsTheme].
CupertinoVideoControlsTheme(
  normal: const CupertinoVideoControlsThemeData(
    // W.I.P.
  ),
  fullscreen: const CupertinoVideoControlsThemeData(
    // W.I.P.
  ),
  child: Scaffold(
    body: VideoControls(
      controller: controller,
    ),
  ),
);
```

##### `NoVideoControls`

- Disable video controls _i.e._ only render video output.
- Theming:
  - No theming applicable.

## Contributing

We welcome contributions to the `universal_video_controls` project! If you have ideas, suggestions, or improvements, please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

Thank you for using `universal_video_controls`!
