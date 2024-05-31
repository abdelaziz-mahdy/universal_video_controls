import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/src/widgets/framework.dart';
import 'package:fvp/mdk.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class FVPPlayer implements AbstractPlayer {
  final Player player;
  bool disposed = false;

  FVPPlayer(this.player){
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
  PlayerState state;

  @override
  PlayerStream stream;

  @override
  // TODO: implement bufferController
  StreamController<Duration> get bufferController => throw UnimplementedError();

  @override
  // TODO: implement bufferingController
  StreamController<bool> get bufferingController => throw UnimplementedError();

  @override
  // TODO: implement completedController
  StreamController<bool> get completedController => throw UnimplementedError();

  @override
  // TODO: implement completer
  Completer<void> get completer => throw UnimplementedError();

  @override
  // TODO: implement durationController
  StreamController<Duration> get durationController => throw UnimplementedError();

  @override
  // TODO: implement heightController
  StreamController<int?> get heightController => throw UnimplementedError();

  @override
  Future<void> next() {
    // TODO: implement next
    throw UnimplementedError();
  }

  @override
  Future<void> playOrPause() {
    // TODO: implement playOrPause
    throw UnimplementedError();
  }

  @override
  // TODO: implement playingController
  StreamController<bool> get playingController => throw UnimplementedError();

  @override
  // TODO: implement positionController
  StreamController<Duration> get positionController => throw UnimplementedError();

  @override
  Future<void> previous() {
    // TODO: implement previous
    throw UnimplementedError();
  }

  @override
  // TODO: implement rateController
  StreamController<double> get rateController => throw UnimplementedError();

  @override
  // TODO: implement release
  List<Future<void> Function()> get release => throw UnimplementedError();

  @override
  // TODO: implement subtitleController
  StreamController<List<String>> get subtitleController => throw UnimplementedError();

  @override
  Widget videoWidget() {
    // TODO: implement videoWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement volumeController
  StreamController<double> get volumeController => throw UnimplementedError();

  @override
  // TODO: implement waitForPlayerInitialization
  Future<void> get waitForPlayerInitialization => throw UnimplementedError();

  @override
  // TODO: implement widthController
  StreamController<int?> get widthController => throw UnimplementedError();
}
