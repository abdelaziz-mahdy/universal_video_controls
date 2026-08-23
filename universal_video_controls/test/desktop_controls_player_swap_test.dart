import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';
import 'package:universal_video_controls/universal_video_controls.dart';

class _FakePlayer extends AbstractPlayer {
  final String name;
  _FakePlayer(this.name);
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

class _Host extends StatefulWidget {
  final GlobalKey<VideoControlsState> videoKey;
  const _Host({required this.videoKey});
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late _FakePlayer player = _FakePlayer('A');

  /// Mirrors an app that replaces its player in place for the next episode:
  /// push the new player through [VideoControlsState.update] and rebuild
  /// with it, keeping the same GlobalKey so the controls State survives.
  void swap(_FakePlayer next) {
    player = next;
    widget.videoKey.currentState?.update(player: next);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: const MaterialDesktopVideoControlsThemeData(
        visibleOnMount: true,
        controlsHoverDuration: Duration(hours: 1),
        // const, as apps naturally write it — the widget instance is
        // canonicalised and identical across rebuilds.
        primaryButtonBar: [MaterialDesktopPlayOrPauseButton()],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(),
      child: VideoControls(
        key: widget.videoKey,
        player: player,
        wakelock: false,
        controls: (state) => MaterialDesktopVideoControls(state),
      ),
    );
  }
}

void main() {
  testWidgets('play/pause button targets the current player after a swap',
      (tester) async {
    final key = GlobalKey<VideoControlsState>();
    await tester.pumpWidget(MaterialApp(home: _Host(videoKey: key)));
    await tester.pump();

    final host = tester.state<_HostState>(find.byType(_Host));
    final a = host.player;
    final b = _FakePlayer('B');

    host.swap(b);
    await tester.pump();
    await a.dispose();

    await tester.tap(find.byType(MaterialDesktopPlayOrPauseButton).first,
        kind: PointerDeviceKind.mouse);
    await tester.pump();

    expect(b.playOrPauseCalls, 1, reason: 'button must drive the new player');
    expect(a.playOrPauseCalls, 0, reason: 'old player must not be touched');

    // The icon must follow the NEW player's playing stream, not the old one's.
    b.state = b.state.copyWith(playing: true);
    b.playingController.add(true);
    await tester.pumpAndSettle();
    final state = tester.state<MaterialDesktopPlayOrPauseButtonState>(
        find.byType(MaterialDesktopPlayOrPauseButton).first);
    expect(state.animation.value, 1.0,
        reason: 'icon should show "pause" once the new player reports playing');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(hours: 1));
    await b.dispose();
  });
}
