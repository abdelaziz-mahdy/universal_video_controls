import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';
import '../common/utils/utils_import.dart';

class VideoViewParametersScreen extends StatefulWidget {
  const VideoViewParametersScreen({super.key});

  @override
  State<VideoViewParametersScreen> createState() =>
      _VideoViewParametersScreenState();
}

class _VideoViewParametersScreenState extends State<VideoViewParametersScreen> {
  late VideoPlayerController _controller;
  late GlobalKey<VideoControlsState> key;
  bool _isInitialized = false;
  BoxFit fit = BoxFit.contain;
  int fitTick = 0;
  int fontSizeTick = 0;
  Timer? fitTimer;
  Timer? fontSizeTimer;

  @override
  void initState() {
    key = GlobalKey<VideoControlsState>();
    _initializeVideoPlayer(getSources()[0]);

    super.initState();
  }

  void _initializeVideoPlayer(String source) async {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    fitTimer?.cancel();
    fontSizeTimer?.cancel();
    super.dispose();
  }

  List<Widget> get items => [
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (fitTimer == null) {
                fitTimer = Timer.periodic(
                  const Duration(seconds: 1),
                  (timer) {
                    if (timer.tick % 3 == 0) {
                      fit =
                          fit == BoxFit.contain ? BoxFit.none : BoxFit.contain;
                      key.currentState?.update(
                        fit: fit,
                      );
                    }
                    if (mounted) {
                      setState(() {
                        fitTick = timer.tick;
                      });
                    }
                  },
                );
              } else {
                fitTimer?.cancel();
                fitTimer = null;
              }
              setState(() {});
            },
            child: Text(
              fitTimer == null
                  ? 'Cycle BoxFit'
                  : 'BoxFit: $fit (${3 - fitTick % 3})',
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (fontSizeTimer == null) {
                fontSizeTimer = Timer.periodic(
                  const Duration(seconds: 1),
                  (timer) {
                    if (timer.tick % 3 == 0) {
                      key.currentState?.update(
                        subtitleViewConfiguration: SubtitleViewConfiguration(
                          style: TextStyle(
                            fontSize: fontSizeFromTick(timer.tick),
                          ),
                        ),
                      );
                    }
                    if (mounted) {
                      setState(() {
                        fontSizeTick = timer.tick;
                      });
                    }
                  },
                );
              } else {
                fontSizeTimer?.cancel();
                fontSizeTimer = null;
              }
              setState(() {});
            },
            child: Text(
              fontSizeTimer == null
                  ? 'Cycle Font'
                  : 'Font: ${fontSizeFromTick(fontSizeTick)}',
            ),
          ),
        ),
      ];

  double fontSizeFromTick(int tick) =>
      20.0 + (tick % 6 < 3 ? tick % 6 : 6 - tick % 6) * 10.0;

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'file',
            tooltip: 'Open [File]',
            onPressed: () => showFilePicker(context, (controller) {
              setState(() {
                _controller.dispose();
                _isInitialized = false;
                _controller = controller;
                _isInitialized = true;
              });
            }),
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            heroTag: 'uri',
            tooltip: 'Open [Uri]',
            onPressed: () => showURIPicker(context, (controller) {
              setState(() {
                _controller.dispose();
                _isInitialized = false;
                _controller = controller;
                _isInitialized = true;
              });
            }),
            child: const Icon(Icons.link),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 8.0,
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.all(32.0),
                              child: VideoControls(
                                key: key,
                                fit: fit,
                                player: VideoPlayerControlsWrapper(_controller),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1.0, thickness: 1.0),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: items,
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  VideoControls(
                    key: key,
                    fit: fit,
                    player: VideoPlayerControlsWrapper(_controller),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                  ),
                  ...items,
                ],
              ),
      ),
    );
  }
}
