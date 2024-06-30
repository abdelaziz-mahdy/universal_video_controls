/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2023 & onwards, Abdelaziz Mahdy <abdelaziz.h.mahdy@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
library;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

import 'video_controls/video_controls.dart';
import 'subtitle/subtitle_view.dart';

/// {@template video_view_parameters}
///
/// VideoViewParameters
/// -------------------
///
/// The attributes of a [VideoControls] widget composed into a single class.
///
/// {@endtemplate}
class VideoViewParameters {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color fill;
  final Alignment alignment;
  final double? aspectRatio;
  final FilterQuality filterQuality;
  final /* VideoControlsBuilder? */ dynamic controls;
  final SubtitleViewConfiguration subtitleViewConfiguration;
  final AbstractPlayer player;

  /// {@macro video_view_parameters}
  VideoViewParameters(
      {required this.width,
      required this.height,
      required this.fit,
      required this.fill,
      required this.alignment,
      required this.aspectRatio,
      required this.filterQuality,
      required this.controls,
      required this.subtitleViewConfiguration,
      required this.player});

  VideoViewParameters copyWith(
      {double? width,
      double? height,
      BoxFit? fit,
      Color? fill,
      Alignment? alignment,
      double? aspectRatio,
      FilterQuality? filterQuality,
      /* VideoControlsBuilder? */ dynamic controls,
      bool? pauseUponEnteringBackgroundMode,
      bool? resumeUponEnteringForegroundMode,
      SubtitleViewConfiguration? subtitleViewConfiguration,
      Future<void> Function()? onEnterFullscreen,
      Future<void> Function()? onExitFullscreen,
      AbstractPlayer? player}) {
    return VideoViewParameters(
        width: width ?? this.width,
        height: height ?? this.height,
        fit: fit ?? this.fit,
        fill: fill ?? this.fill,
        alignment: alignment ?? this.alignment,
        aspectRatio: aspectRatio ?? this.aspectRatio,
        filterQuality: filterQuality ?? this.filterQuality,
        controls: controls ?? this.controls,
        subtitleViewConfiguration:
            subtitleViewConfiguration ?? this.subtitleViewConfiguration,
        player: player ?? this.player);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoViewParameters &&
          other.width == width &&
          other.height == height &&
          other.fit == fit &&
          other.fill == fill &&
          other.alignment == alignment &&
          other.aspectRatio == aspectRatio &&
          other.filterQuality == filterQuality &&
          other.controls == controls &&
          other.subtitleViewConfiguration == subtitleViewConfiguration &&
          other.player == player;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      fit.hashCode ^
      fill.hashCode ^
      alignment.hashCode ^
      aspectRatio.hashCode ^
      filterQuality.hashCode ^
      controls.hashCode ^
      subtitleViewConfiguration.hashCode ^
      player.hashCode;
}
