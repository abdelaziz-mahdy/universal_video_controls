library universal_video_controls_video_player;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class VideoPlayerControlsWrapper extends AbstractPlayer {
  final VideoPlayerController controller;
  bool disposed = false;

  VideoPlayerControlsWrapper(this.controller) {
    _initialize();
  }

  void _initialize() {
    controller.addListener(() {
      final isPlaying = controller.value.isPlaying;
      final isCompleted = controller.value.position == controller.value.duration;

      state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: controller.value.position,
        duration: controller.value.duration,
        buffering: controller.value.isBuffering,
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
      );

      if (!playingController.isClosed) {
        playingController.add(isPlaying);
      }

      if (!completedController.isClosed) {
        completedController.add(isCompleted);
      }

      if (!bufferingController.isClosed) {
        bufferingController.add(controller.value.isBuffering);
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
    });
  }

  @override
  Future<void> dispose({bool synchronized = true}) async {
    if (disposed) return;
    disposed = true;
    await controller.dispose();
    await super.dispose();
  }

  @override
  Future<void> play({bool synchronized = true}) async {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    await controller.play();
  }

  @override
  Future<void> pause({bool synchronized = true}) async {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    await controller.pause();
  }

  @override
  Future<void> seek(Duration duration, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    await controller.seekTo(duration);
  }

  @override
  Future<void> setVolume(double volume, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    await controller.setVolume(volume);
  }

  @override
  Future<void> setRate(double rate, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    await controller.setPlaybackSpeed(rate);
  }

  @override
  Future<void> playOrPause() {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    if (state.playing) {
      controller.pause();
    } else {
      controller.play();
    }
    return Future.value();
  }

  @override
  Widget videoWidget() {
    if (disposed) throw AssertionError('[VideoPlayerController] has been disposed');
    return VideoPlayer(controller);
  }
}