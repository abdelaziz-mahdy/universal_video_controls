import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';
import '../common/utils/utils_import.dart';

class ProgrammaticFullscreen extends StatefulWidget {
  const ProgrammaticFullscreen({super.key});

  @override
  State<ProgrammaticFullscreen> createState() => _ProgrammaticFullscreenState();
}

class _ProgrammaticFullscreenState extends State<ProgrammaticFullscreen> {
  late VideoPlayerController _controller;
  late GlobalKey<VideoControlsState> key;
  bool _isInitialized = false;
  int tick = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    key = GlobalKey<VideoControlsState>();
    _initializeVideoPlayer(getSources()[0]);
  }

  void _initializeVideoPlayer(String source) async {
    _controller = await initializeVideoPlayer(source);
    setState(() {
      _isInitialized = true;
    });
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint(_controller.value.errorDescription);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  List<Widget> get items => [
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (timer == null) {
                timer = Timer.periodic(
                  const Duration(seconds: 1),
                  (timer) {
                    if (timer.tick % 3 == 0) {
                      debugPrint(
                          'Fullscreen: ${key.currentState?.isFullscreen()}');
                      if (key.currentState?.isFullscreen() ?? false) {
                        key.currentState?.exitFullscreen();
                      } else {
                        key.currentState?.enterFullscreen();
                      }
                    }
                    if (mounted) {
                      setState(() {
                        tick = timer.tick;
                      });
                    }
                  },
                );
              } else {
                timer?.cancel();
                timer = null;
              }

              setState(() {});
            },
            child: Text(
              timer == null ? 'Cycle Fullscreen' : '${3 - tick % 3}',
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ];

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
                              child: _isInitialized
                                  ? VideoControls(
                                      key: key,
                                      player: VideoPlayerControlsWrapper(
                                          _controller),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator()),
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
                  if (_isInitialized)
                    VideoControls(
                      key: key,
                      player: VideoPlayerControlsWrapper(_controller),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  ...items,
                ],
              ),
      ),
    );
  }
}
