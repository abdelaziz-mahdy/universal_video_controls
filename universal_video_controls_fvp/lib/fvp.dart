import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';
export 'package:fvp/mdk.dart';

class FVPPlayer extends AbstractPlayer {
  final Player player;
  bool disposed = false;

  FVPPlayer(this.player) {
    _initialize();
  }

  void _initialize() {
    player.onStateChanged((oldState, newState) {
      state = state.copyWith(
        playing: newState == PlaybackState.playing,
        completed: newState == PlaybackState.stopped,
      );

      if (!playingController.isClosed) {
        playingController.add(newState == PlaybackState.playing);
      }

      if (!completedController.isClosed) {
        completedController.add(newState == PlaybackState.stopped);
      }

      if (newState == PlaybackState.paused) {
        state = state.copyWith(playing: false);
        if (!playingController.isClosed) {
          playingController.add(false);
        }
      }
    });

    player.onEvent((ev) {
      if (ev.category == "reader.buffering") {
        final pos = player.position;
        final bufLen = player.buffered();
        state = state.copyWith(buffer: Duration(milliseconds: bufLen));
        if (!bufferController.isClosed) {
          bufferController.add(Duration(milliseconds: bufLen));
        }
      }
      // Add more event handling logic here as needed
    });

    player.onMediaStatus((oldStatus, newStatus) {
      if (!oldStatus.test(MediaStatus.loaded) &&
          newStatus.test(MediaStatus.loaded)) {
        final info = player.mediaInfo;
        var size = const Size(0, 0);
        if (info.video != null) {
          final vc = info.video![0].codec;
          size = Size(vc.width.toDouble(),
              (vc.height.toDouble() / vc.par).roundToDouble());
          if (info.video![0].rotation % 180 == 90) {
            size = Size(size.height, size.width);
          }
        }
        state = state.copyWith(
          duration: Duration(microseconds: info.duration * 1000),
          width: size.width.toInt(),
          height: size.height.toInt(),
        );
        if (!durationController.isClosed) {
          durationController.add(Duration(microseconds: info.duration * 1000));
        }
        if (!widthController.isClosed) {
          widthController.add(size.width.toInt());
        }
        if (!heightController.isClosed) {
          heightController.add(size.height.toInt());
        }
      } else if (!oldStatus.test(MediaStatus.buffering) &&
          newStatus.test(MediaStatus.buffering)) {
        state = state.copyWith(buffering: true);
        if (!bufferingController.isClosed) {
          bufferingController.add(true);
        }
      } else if (!oldStatus.test(MediaStatus.buffered) &&
          newStatus.test(MediaStatus.buffered)) {
        state = state.copyWith(buffering: false);
        if (!bufferingController.isClosed) {
          bufferingController.add(false);
        }
      }
      return true;
    });
  }

  @override
  Future<void> dispose({bool synchronized = true}) async {
    if (disposed) return;
    disposed = true;

    player.dispose();
  }

  @override
  Future<void> play({bool synchronized = true}) async {
    if (disposed) throw AssertionError('[Player] has been disposed');
    player.state = PlaybackState.playing;
  }

  @override
  Future<void> pause({bool synchronized = true}) async {
    if (disposed) throw AssertionError('[Player] has been disposed');
    player.state = PlaybackState.paused;
  }

  @override
  Future<void> seek(Duration duration, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[Player] has been disposed');
    await player.seek(position: duration.inMilliseconds);
  }

  @override
  Future<void> setVolume(double volume, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[Player] has been disposed');
    player.volume = volume;
  }

  @override
  Future<void> setRate(double rate, {bool synchronized = true}) async {
    if (disposed) throw AssertionError('[Player] has been disposed');
    player.playbackRate = rate;
  }

  @override
  Future<void> playOrPause() {
    if (disposed) throw AssertionError('[Player] has been disposed');
    if (state.playing) {
      player.state = PlaybackState.paused;
    } else {
      player.state = PlaybackState.playing;
    }
    return Future.value();
  }

  // @override
  // Future<void> previous() {
  //   // TODO: implement previous
  //   throw UnimplementedError();
  // }

  @override
  Widget videoWidget() {
    if (disposed) throw AssertionError('[Player] has been disposed');
    return Texture(textureId: player.textureId.value!);
  }
}
