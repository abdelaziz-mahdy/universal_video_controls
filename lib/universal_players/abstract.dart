import 'dart:async';
import 'dart:typed_data';
import 'package:meta/meta.dart';
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
  late PlayerState state = PlayerState();

  /// Current state of the player available as listenable [Stream]s.
  late PlayerStream stream = PlayerStream(
    playingController.stream.distinct(
      (previous, current) => previous == current,
    ),
    positionController.stream.distinct(
      (previous, current) => previous == current,
    ),
    widthController.stream.distinct(
      (previous, current) => previous == current,
    ),
    heightController.stream.distinct(
      (previous, current) => previous == current,
    ),
    subtitleController.stream.distinct(
      (previous, current) => ListEquality().equals(previous, current),
    ),
    bufferingController.stream.distinct(
      (previous, current) => previous == current,
    ),
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
      ],
    );
  }

  Future<void> play() {
    throw UnimplementedError('[AbstractPlayer.play] is not implemented');
  }

  Future<void> pause() {
    throw UnimplementedError('[AbstractPlayer.pause] is not implemented');
  }

  @protected
  final StreamController<bool> playingController = StreamController<bool>.broadcast();

  @protected
  final StreamController<Duration> positionController = StreamController<Duration>.broadcast();

  @protected
  final StreamController<int?> widthController = StreamController<int?>.broadcast();

  @protected
  final StreamController<int?> heightController = StreamController<int?>.broadcast();

  @protected
  final StreamController<List<String>> subtitleController = StreamController<List<String>>.broadcast();

  @protected
  final StreamController<bool> bufferingController = StreamController<bool>.broadcast();

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

  /// {@macro player_state}
  const PlayerState({
    this.playing = false,
    this.position = Duration.zero,
    this.width,
    this.height,
    this.subtitle = const ['', ''],
    this.buffering = false,
  });

  PlayerState copyWith({
    bool? playing,
    Duration? position,
    int? width,
    int? height,
    List<String>? subtitle,
    bool? buffering,
  }) {
    return PlayerState(
      playing: playing ?? this.playing,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      subtitle: subtitle ?? this.subtitle,
      buffering: buffering ?? this.buffering,
    );
  }

  @override
  String toString() => 'PlayerState('
      'playing: $playing, '
      'position: $position, '
      'width: $width, '
      'height: $height, '
      'subtitle: $subtitle, '
      'buffering: $buffering'
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

  /// {@macro player_stream}
  const PlayerStream(
    this.playing,
    this.position,
    this.width,
    this.height,
    this.subtitle,
    this.buffering,
  );
}
