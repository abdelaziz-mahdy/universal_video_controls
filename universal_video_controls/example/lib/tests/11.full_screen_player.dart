import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:universal_video_controls_example/common/sources/sources.dart';
import 'package:universal_video_controls_example/common/utils/utils_import.dart';

class FullScreenPlayer extends StatefulWidget {
  const FullScreenPlayer({super.key});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late final VideoPlayerController _controller;
  late final GlobalKey<VideoControlsState> key =
      GlobalKey<VideoControlsState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(getSources()[0]);
  }

  Future<void> _initializeVideoPlayer(String source) async {
    _controller = initializeVideoPlayer(source);
    setState(() {
      _isInitialized = true;
    });
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint(_controller.value.errorDescription);
      }
    });
    await _controller.initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await key.currentState?.enterFullscreen();
      //
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return // Wrap [Video] widget with [MaterialVideoControlsTheme].
        MaterialVideoControlsTheme(
            normal: MaterialVideoControlsThemeData(
              topButtonBar: topBar(context),
            ),
            fullscreen: MaterialVideoControlsThemeData(
              topButtonBar: topBar(context),
            ),
            child: // Wrap [Video] widget with [MaterialDesktopVideoControlsTheme].
                MaterialDesktopVideoControlsTheme(
                    normal: MaterialDesktopVideoControlsThemeData(
                      topButtonBar: topBar(context),
                    ),
                    fullscreen: MaterialDesktopVideoControlsThemeData(
                      topButtonBar: topBar(context),
                    ),
                    child: VideoControls(
                      key: key,
                      player: VideoPlayerControlsWrapper(_controller),
                      onEnterFullscreen: () async {
                        await defaultEnterNativeFullscreen();
                      },
                      onExitFullscreen: () async {
                        await defaultExitNativeFullscreen();
                        if (!UniversalPlatform.isDesktop) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      },
                    )));
  }

  List<Widget> topBar(BuildContext context) {
    return [
      MaterialDesktopCustomButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (key.currentState?.isFullscreen() ?? false) {
            key.currentState?.exitFullscreen();
          }
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      const Spacer(),
    ];
  }
}
