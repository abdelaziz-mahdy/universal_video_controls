import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

/// {@template abstract_player}
/// AbstractPlayer
/// --------------
///
/// This class provides the interface for abstract player implementations.
/// The specific implementations are expected to implement the methods accordingly.
///
/// The subclasses are then used in composition with the [Player] class, based on the platform the application is running on.
///
/// {@endtemplate}
abstract class AbstractPlayer {
  /// {@macro abstract_player}
  AbstractPlayer();

  /// Current state of the player.
  late PlayerState state = const PlayerState();

  /// Current state of the player available as listenable [Stream]s.
  late PlayerStream stream = PlayerStream(
    playingController.stream
        .distinct((previous, current) => previous == current),
    positionController.stream
        .distinct((previous, current) => previous == current),
    widthController.stream.distinct((previous, current) => previous == current),
    heightController.stream
        .distinct((previous, current) => previous == current),
    subtitleController.stream.distinct(
        (previous, current) => const ListEquality().equals(previous, current)),
    bufferingController.stream
        .distinct((previous, current) => previous == current),
    bufferController.stream
        .distinct((previous, current) => previous == current),
    durationController.stream
        .distinct((previous, current) => previous == current),
    // playlistController.stream.distinct((previous, current) => ListEquality().equals(previous, current)),
    volumeController.stream
        .distinct((previous, current) => previous == current),
    rateController.stream.distinct((previous, current) => previous == current),
    completedController.stream
        .distinct((previous, current) => previous == current),
  );

  @mustCallSuper
  Future<void> dispose() async {
    await Future.wait(
      [
        playingController.close(),
        positionController.close(),
        widthController.close(),
        heightController.close(),
        subtitleController.close(),
        bufferingController.close(),
        bufferController.close(),
        durationController.close(),
        // playlistController.close(),
        volumeController.close(),
        rateController.close(),
        completedController.close(),
      ],
    );
  }

  Future<void> play() {
    throw UnimplementedError('[AbstractPlayer.play] is not implemented');
  }

  Future<void> playOrPause() {
    throw UnimplementedError('[AbstractPlayer.playOrPause] is not implemented');
  }

  Future<void> pause() {
    throw UnimplementedError('[AbstractPlayer.pause] is not implemented');
  }

  Future<void> seek(Duration duration) {
    throw UnimplementedError('[AbstractPlayer.seek] is not implemented');
  }

  Future<void> setVolume(double volume) {
    throw UnimplementedError('[AbstractPlayer.setVolume] is not implemented');
  }

  // Future<void> next() {
  //   throw UnimplementedError('[AbstractPlayer.next] is not implemented');
  // }

  // Future<void> previous() {
  //   throw UnimplementedError('[AbstractPlayer.previous] is not implemented');
  // }

  Future<void> setRate(double rate) {
    throw UnimplementedError('[AbstractPlayer.setRate] is not implemented');
  }

  Widget videoWidget() {
    throw UnimplementedError('[AbstractPlayer.videoWidget] is not implemented');
  }
  // bool isPlaylist() {
  //   throw UnimplementedError('[AbstractPlayer.isPlaylist] is not implemented');
  // }

  @protected
  final StreamController<bool> playingController =
      StreamController<bool>.broadcast();

  @protected
  final StreamController<Duration> positionController =
      StreamController<Duration>.broadcast();

  @protected
  final StreamController<int?> widthController =
      StreamController<int?>.broadcast();

  @protected
  final StreamController<int?> heightController =
      StreamController<int?>.broadcast();

  @protected
  final StreamController<List<String>> subtitleController =
      StreamController<List<String>>.broadcast();

  @protected
  final StreamController<bool> bufferingController =
      StreamController<bool>.broadcast();

  @protected
  final StreamController<Duration> bufferController =
      StreamController<Duration>.broadcast();

  @protected
  final StreamController<Duration> durationController =
      StreamController<Duration>.broadcast();

  // @protected
  // final StreamController<List<Media>> playlistController = StreamController<List<Media>>.broadcast();

  @protected
  final StreamController<double> volumeController =
      StreamController<double>.broadcast();

  @protected
  final StreamController<double> rateController =
      StreamController<double>.broadcast();

  @protected
  final StreamController<bool> completedController =
      StreamController<bool>.broadcast();

  /// [Completer] to wait for initialization of this instance.
  final Completer<void> completer = Completer<void>();

  /// [Future<void>] to wait for initialization of this instance.
  Future<void> get waitForPlayerInitialization => completer.future;

  /// Publicly defined clean-up [Function]s which must be called before [dispose].
  final List<Future<void> Function()> release = [];
}

/// {@template player_state}
///
/// PlayerState
/// -----------
///
/// Instantaneous state of the [Player].
///
/// {@endtemplate}
class PlayerState {
  /// Whether playing or not.
  final bool playing;

  /// Current playback position.
  final Duration position;

  /// Currently playing video's width.
  final int? width;

  /// Currently playing video's height.
  final int? height;

  /// Currently displayed subtitle.
  final List<String> subtitle;

  /// Whether buffering or not.
  final bool buffering;

  /// Current buffer duration.
  final Duration buffer;

  /// Duration of the media.
  final Duration duration;

  // /// Current playlist.
  // final List<Media> playlist;

  /// Current volume.
  final double volume;

  /// Current playback rate.
  final double rate;

  /// Whether playback is completed or not.
  final bool completed;

  /// {@macro player_state}
  const PlayerState({
    this.playing = false,
    this.position = Duration.zero,
    this.width,
    this.height,
    this.subtitle = const ['', ''],
    this.buffering = false,
    this.buffer = Duration.zero,
    this.duration = Duration.zero,
    // this.playlist = const [],
    this.volume = 1.0,
    this.rate = 1.0,
    this.completed = false,
  });

  PlayerState copyWith({
    bool? playing,
    Duration? position,
    int? width,
    int? height,
    List<String>? subtitle,
    bool? buffering,
    Duration? buffer,
    Duration? duration,
    // List<Media>? playlist,
    double? volume,
    double? rate,
    bool? completed,
  }) {
    return PlayerState(
      playing: playing ?? this.playing,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      subtitle: subtitle ?? this.subtitle,
      buffering: buffering ?? this.buffering,
      buffer: buffer ?? this.buffer,
      duration: duration ?? this.duration,
      // playlist: playlist ?? this.playlist,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() => 'PlayerState('
      'playing: $playing, '
      'position: $position, '
      'width: $width, '
      'height: $height, '
      'subtitle: $subtitle, '
      'buffering: $buffering, '
      'buffer: $buffer, '
      'duration: $duration, '
      // 'playlist: $playlist, '
      'volume: $volume, '
      'rate: $rate, '
      'completed: $completed'
      ')';
}

/// {@template player_stream}
///
/// PlayerStream
/// ------------
///
/// Event [Stream]s for subscribing to [Player] events.
///
/// {@endtemplate}
class PlayerStream {
  /// Whether playing or not.
  final Stream<bool> playing;

  /// Current playback position.
  final Stream<Duration> position;

  /// Currently playing video's width.
  final Stream<int?> width;

  /// Currently playing video's height.
  final Stream<int?> height;

  /// Currently displayed subtitle.
  final Stream<List<String>> subtitle;

  /// Whether buffering or not.
  final Stream<bool> buffering;

  /// Current buffer duration.
  final Stream<Duration> buffer;

  /// Duration of the media.
  final Stream<Duration> duration;

  // /// Current playlist.
  // final Stream<List<Media>> playlist;

  /// Current volume.
  final Stream<double> volume;

  /// Current playback rate.
  final Stream<double> rate;

  /// Whether playback is completed or not.
  final Stream<bool> completed;

  /// {@macro player_stream}
  const PlayerStream(
    this.playing,
    this.position,
    this.width,
    this.height,
    this.subtitle,
    this.buffering,
    this.buffer,
    this.duration,
    // this.playlist,
    this.volume,
    this.rate,
    this.completed,
  );
}
