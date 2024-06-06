# universal_video_controls_video_player

## Overview

The `universal_video_controls_video_player` package provides an implementation of the `AbstractPlayer` interface using the `video_player` package. This allows you to use the `universal_video_controls` package with the `video_player` package seamlessly.

## Getting Started

### Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  universal_video_controls_video_player: ^1.0.1
  universal_video_controls: ^1.0.10
  video_player: ^2.2.5
```

Run `flutter pub get` to install the packages.

### Usage

To use the `universal_video_controls_video_player` package:

1. **Initialize** your `VideoPlayerController` with the desired video source.
2. **Wrap** the `VideoPlayerController` with `VideoPlayerControlsWrapper`.
3. **Use** the `VideoPlayerControlsWrapper` with the `VideoControls` widget from the `universal_video_controls` package.

### Key Components

- **VideoPlayerControlsWrapper**: A wrapper for the `VideoPlayerController` that implements the `AbstractPlayer` interface. This allows the `universal_video_controls` to control the video player.

### Example Setup

1. Create a `VideoPlayerController` with a video source.
2. Wrap the `VideoPlayerController` with `VideoPlayerControlsWrapper`.
3. Use the `VideoPlayerControlsWrapper` with `VideoControls`.

This setup ensures that the `universal_video_controls` package can control the video playback using the `video_player` package.

## Contributing

We welcome contributions to the `universal_video_controls_video_player` project! If you have ideas, suggestions, or improvements, please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

Thank you for using `universal_video_controls_video_player`!
