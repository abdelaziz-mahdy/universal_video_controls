import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';
import 'package:universal_video_controls/universal_video_controls.dart';

/// Minimal player: counts play/pause toggles, renders a plain box.
class _FakePlayer extends AbstractPlayer {
  int playOrPauseCalls = 0;

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playOrPause() async {
    playOrPauseCalls++;
  }

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

void main() {
  testWidgets('desktop controls: a slow click on a control-bar button does not '
      'also toggle play/pause', (tester) async {
    final player = _FakePlayer();
    var buttonPresses = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: MaterialDesktopVideoControlsTheme(
          normal: MaterialDesktopVideoControlsThemeData(
            visibleOnMount: true,
            // Keep the bars mounted for the whole test.
            controlsHoverDuration: const Duration(hours: 1),
            primaryButtonBar: [
              IconButton(
                key: const Key('transport'),
                icon: const Icon(Icons.skip_next),
                onPressed: () => buttonPresses++,
              ),
            ],
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
    // Let the controls mount (they appear on first build, then auto-hide).
    await tester.pump();

    // Press and HOLD past the tap recognizer's 100ms deadline before release.
    // The ancestor GestureDetector's onTapDown fires at the deadline even
    // though the button wins the arena on release.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('transport'))),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump();

    expect(buttonPresses, 1, reason: 'the button itself must still fire');
    expect(
      player.playOrPauseCalls,
      0,
      reason: 'the click must not leak through to the video surface',
    );

    // A click on the bare video surface still toggles playback.
    await tester.tapAt(const Offset(20, 300), kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(player.playOrPauseCalls, 1);

    // Drain the controls' auto-hide timer so the test ends clean.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(hours: 1));
    await player.dispose();
  });
}
