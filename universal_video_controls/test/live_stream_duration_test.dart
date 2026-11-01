import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';
import 'package:universal_video_controls/universal_video_controls.dart';

/// fvp reports live streams with the largest representable [Duration].
const _fvpLiveDuration = Duration(microseconds: 9223372036854775807);

/// Minimal player with a fixed position and duration.
class _FakePlayer extends AbstractPlayer {
  _FakePlayer({required Duration duration}) {
    state = state.copyWith(
      duration: duration,
      position: const Duration(seconds: 18),
    );
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playOrPause() async {}

  @override
  Future<void> seek(Duration duration) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setRate(double rate) async {}

  @override
  void setSubtitle(String subtitle) {}

  @override
  Widget videoWidget() => const ColoredBox(color: Colors.black);
}

Future<_FakePlayer> _pumpMobile(WidgetTester tester, Duration duration) async {
  final player = _FakePlayer(duration: duration);
  await tester.pumpWidget(
    MaterialApp(
      home: MaterialVideoControlsTheme(
        normal: const MaterialVideoControlsThemeData(
          visibleOnMount: true,
          // Keep the bars mounted for the whole test.
          controlsHoverDuration: Duration(hours: 1),
        ),
        fullscreen: const MaterialVideoControlsThemeData(),
        child: VideoControls(
          player: player,
          wakelock: false,
          controls: (state) => MaterialVideoControls(state),
        ),
      ),
    ),
  );
  await tester.pump();
  return player;
}

Future<_FakePlayer> _pumpDesktop(WidgetTester tester, Duration duration) async {
  final player = _FakePlayer(duration: duration);
  await tester.pumpWidget(
    MaterialApp(
      home: MaterialDesktopVideoControlsTheme(
        normal: const MaterialDesktopVideoControlsThemeData(
          visibleOnMount: true,
          // Keep the bars mounted for the whole test.
          controlsHoverDuration: Duration(hours: 1),
        ),
        fullscreen: const MaterialDesktopVideoControlsThemeData(),
        child: VideoControls(
          player: player,
          wakelock: false,
          controls: (state) => MaterialDesktopVideoControls(state),
        ),
      ),
    ),
  );
  await tester.pump();
  return player;
}

/// Drains the controls' auto-hide timer so the test ends clean.
Future<void> _tearDown(WidgetTester tester, _FakePlayer player) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(hours: 1));
  await player.dispose();
}

void main() {
  group('mobile controls', () {
    testWidgets('live stream shows LIVE and elapsed time, no seek bar',
        (tester) async {
      final player = await _pumpMobile(tester, _fvpLiveDuration);

      expect(find.text('LIVE • 00:18'), findsOneWidget);
      expect(find.textContaining('106751991'), findsNothing);
      expect(find.byType(MaterialSeekBar), findsOneWidget);
      expect(
        tester.getSize(find.byType(MaterialSeekBar)).height,
        0,
        reason: 'a live stream has no timeline to seek on',
      );

      await _tearDown(tester, player);
    });

    testWidgets('regular video keeps position / duration and seek bar',
        (tester) async {
      final player = await _pumpMobile(tester, const Duration(minutes: 1));

      expect(find.text('00:18 / 01:00'), findsOneWidget);
      expect(tester.getSize(find.byType(MaterialSeekBar)).height, isNonZero);

      await _tearDown(tester, player);
    });
  });

  group('desktop controls', () {
    testWidgets('live stream shows LIVE and elapsed time, no seek bar',
        (tester) async {
      final player = await _pumpDesktop(tester, _fvpLiveDuration);

      expect(find.text('LIVE • 00:18'), findsOneWidget);
      expect(find.textContaining('106751991'), findsNothing);
      expect(
        tester.getSize(find.byType(MaterialDesktopSeekBar)).height,
        0,
        reason: 'a live stream has no timeline to seek on',
      );

      await _tearDown(tester, player);
    });

    testWidgets('regular video keeps position / duration and seek bar',
        (tester) async {
      final player = await _pumpDesktop(tester, const Duration(minutes: 1));

      expect(find.text('00:18 / 01:00'), findsOneWidget);
      expect(
        tester.getSize(find.byType(MaterialDesktopSeekBar)).height,
        isNonZero,
      );

      await _tearDown(tester, player);
    });
  });
}
