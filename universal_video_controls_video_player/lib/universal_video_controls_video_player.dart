library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class VideoPlayerControlsWrapper extends AbstractPlayer {
  /// The video player controller
  final VideoPlayerController controller;

  /// true if the controller has been disposed
  bool disposed = false;

  /// position updater forcer timer
  Timer? _positionUpdaterForcerTimer;
  VideoPlayerControlsWrapper(this.controller) {
    _initialize();
  }

  void startPositionUpdaterForcer() {
    _positionUpdaterForcerTimer?.cancel();
    _positionUpdaterForcerTimer =
        Timer.periodic(Duration(milliseconds: 100), (timer) {
      _positionUpdaterForcer();
    });
  }

  void stopPositionUpdaterForcer() {
    _positionUpdaterForcerTimer?.cancel();
  }

  /// These parts exists in the video_player package but slightly edited to be called from outside of the class
  Future<void> _positionUpdaterForcer() async {
    Duration? position = await controller.position;
    if (position == null) {
      return;
    }
    VideoPlayerValue value = controller.value;
    if (position > value.duration) {
      position = value.duration;
    }
    value = value.copyWith(
      position: position,
      caption: await _getCaptionAt(position),
      isCompleted: position == value.duration,
    );
  }

  Future<Caption> _getCaptionAt(Duration position) async {
    /// the internal [ClosedCaptionFile]
    ClosedCaptionFile? closedCaptionFile;
    closedCaptionFile = await controller.closedCaptionFile;
    if (closedCaptionFile == null) {
      return Caption.none;
    }

    VideoPlayerValue value = controller.value;
    final Duration delayedPosition = position + value.captionOffset;
    // TODO(johnsonmh): This would be more efficient as a binary search.
    for (final Caption caption in (closedCaptionFile).captions) {
      if (caption.start <= delayedPosition && caption.end >= delayedPosition) {
        return caption;
      }
    }

    return Caption.none;
  }

  void _initialize() {
    if (isPlaying) {
      startPositionUpdaterForcer();
    }
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: controller.value.position,
        duration: controller.value.duration,
        buffering: true, // video starts as buffering
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
        volume: controller.value.volume * 100,

        /// there is no captions loaded, ignore [VideoPlayerController] captions
        subtitle: controller.closedCaptionFile == null
            ? null
            : [controller.value.caption.text],
        buffer: controller.value.buffered.lastOrNull?.end);
    controller.addListener(_listener);
  }

  void _listener() {
    bool isBuffering = controller.value.isBuffering
        ? true
        : controller.value.duration.inMilliseconds == 0
            ? true
            : false;

    /// if the playing state has changed to paused, stop the position updater forcer
    /// this is paused
    if (state.playing == true && controller.value.isPlaying == false) {
      stopPositionUpdaterForcer();
    }

    /// this is playing
    if (state.playing == false && controller.value.isPlaying == true) {
      startPositionUpdaterForcer();
    }
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: controller.value.position,
        duration: controller.value.duration,
        buffering: isBuffering,
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
        volume: controller.value.volume * 100,
        subtitle: controller.closedCaptionFile == null
            ? null
            : [controller.value.caption.text],
        buffer: controller.value.buffered.lastOrNull?.end);

    if (!playingController.isClosed) {
      playingController.add(isPlaying);
    }

    if (!completedController.isClosed) {
      completedController.add(isCompleted);
    }

    if (!bufferingController.isClosed) {
      bufferingController.add(isBuffering);
    }

    if (!positionController.isClosed) {
      positionController.add(controller.value.position);
    }

    if (!durationController.isClosed) {
      durationController.add(controller.value.duration);
    }

    if (!widthController.isClosed) {
      widthController.add(controller.value.size.width.toInt());
    }

    if (!heightController.isClosed) {
      heightController.add(controller.value.size.height.toInt());
    }

    if (!volumeController.isClosed) {
      volumeController.add(controller.value.volume * 100);
    }

    /// there is no captions loaded, ignore [VideoPlayerController] captions
    if (!subtitleController.isClosed && controller.closedCaptionFile != null) {
      subtitleController.add([controller.value.caption.text]);
    }
    if (!bufferController.isClosed) {
      if (controller.value.buffered.lastOrNull?.end != null) {
        bufferController.add(controller.value.buffered.lastOrNull!.end);
      }
    }
  }

  bool get isPlaying => controller.value.isPlaying;

  bool get isCompleted =>
      controller.value.position == controller.value.duration;

  @override
  Future<void> dispose({bool synchronized = true}) async {
    if (disposed) return;
    disposed = true;
    controller.removeListener(_listener);
    _positionUpdaterForcerTimer?.cancel();
    await super.dispose();
  }

  @override
  Future<void> play({bool synchronized = true}) async {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    await controller.play();
  }

  @override
  Future<void> pause({bool synchronized = true}) async {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    await controller.pause();
  }

  @override
  Future<void> seek(Duration duration, {bool synchronized = true}) async {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    await controller.seekTo(duration);
  }

  @override
  Future<void> setVolume(double volume, {bool synchronized = true}) async {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    await controller.setVolume(volume / 100);
  }

  @override
  Future<void> setRate(double rate, {bool synchronized = true}) async {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    await controller.setPlaybackSpeed(rate);
  }

  @override
  Future<void> playOrPause() {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    if (state.playing) {
      controller.pause();
    } else {
      controller.play();
    }
    return Future.value();
  }

  @override
  Widget videoWidget() {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    return VideoPlayer(controller);
  }

  @override

  /// Set subtitle (this can be used to set subtitles based on a custom parser)
  void setSubtitle(String subtitle) {
    if (disposed) {
      throw AssertionError('[VideoPlayerController] has been disposed');
    }
    return subtitleController.add([subtitle]);
  }
}
