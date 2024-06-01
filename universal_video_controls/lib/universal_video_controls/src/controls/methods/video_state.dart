/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
library;
import 'package:flutter/widgets.dart';
import '../../../../universal_players/abstract.dart';
import '../../../../universal_video_controls.dart';

/// Returns the [VideoControlsState] associated with the [VideoControls] present in the current [BuildContext].
VideoControlsState state(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state;

/// Returns the [ValueNotifier<BuildContext>] associated with the [VideoControls] present in the current [BuildContext].
ValueNotifier<BuildContext?> contextNotifier(BuildContext context) =>
    VideoStateInheritedWidget.of(context).contextNotifier;

/// Returns the [ValueNotifier<VideoViewParameters>] associated with the [VideoControls] present in the current [BuildContext].
ValueNotifier<VideoViewParameters> videoViewParametersNotifier(
        BuildContext context) =>
    VideoStateInheritedWidget.of(context).videoViewParametersNotifier;

/// Returns the [AbstractPlayer] associated with the [VideoControls] present in the current [BuildContext].
AbstractPlayer player(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.player;

/// Returns the callback which must be invoked when the video enters fullscreen mode.
Future<void> Function()? onEnterFullscreen(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.onEnterFullscreen;

/// Returns the callback which must be invoked when the video exits fullscreen mode.
Future<void> Function()? onExitFullscreen(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.onExitFullscreen;
