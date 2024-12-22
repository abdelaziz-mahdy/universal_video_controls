library universal_video_controls_video_player;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class VideoPlayerControlsWrapper extends AbstractPlayer {
  /// The video player controller
  final VideoPlayerController controller;

  /// true if the controller has been disposed
  bool disposed = false;

  VideoPlayerControlsWrapper(this.controller) {
    _initialize();
  }

  void _initialize() {
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
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: controller.value.position,
        duration: controller.value.duration,
        buffering: isBuffering,
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
        volume: controller.value.volume * 100,
        subtitle: [controller.value.caption.text],
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
