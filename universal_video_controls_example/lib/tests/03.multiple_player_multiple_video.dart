import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils_import.dart';

class MultiplePlayerMultipleVideoScreen extends StatefulWidget {
  const MultiplePlayerMultipleVideoScreen({super.key});

  @override
  State<MultiplePlayerMultipleVideoScreen> createState() =>
      _MultiplePlayerMultipleVideoScreenState();
}

class _MultiplePlayerMultipleVideoScreenState
    extends State<MultiplePlayerMultipleVideoScreen> {
  final List<VideoPlayerController> _controllers = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  void _initializeVideoPlayers() async {
    for (var source in getSources()) {
      final controller = initializeVideoPlayer(source);
      _controllers.add(controller);
      controller.initialize();
    }
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Widget> get items => [
        for (int i = 0; i < getSources().length; i++)
          ListTile(
            title: Text(
              'Video $i',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              setState(() {
                for (var controller in _controllers) {
                  controller.dispose();
                }
                _controllers.clear();
                _initializeVideoPlayers();
              });
            },
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: SizedBox.expand(
        child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var controller in _controllers)
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: _isInitialized
                            ? VideoControls(
                                player: VideoPlayerControlsWrapper(controller),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              )
            : ListView(
                children: [
                  for (var controller in _controllers)
                    if (_isInitialized)
                      VideoControls(
                        player: VideoPlayerControlsWrapper(controller),
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
