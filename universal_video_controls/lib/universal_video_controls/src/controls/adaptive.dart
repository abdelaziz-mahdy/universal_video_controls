/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
library;

// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import '../../../universal_video_controls.dart';

/// {@template adaptive_video_controls}
///
/// [VideoControls] controls based on the running platform.
///
/// {@endtemplate}
Widget AdaptiveVideoControls(VideoControlsState state) {
  switch (Theme.of(state.context).platform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return MaterialVideoControls(state);
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return MaterialDesktopVideoControls(state);
    default:
      return NoVideoControls(state);
  }
}
