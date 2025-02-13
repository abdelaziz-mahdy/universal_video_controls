import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils_import.dart';

class StressTestScreen extends StatefulWidget {
  const StressTestScreen({super.key});

  @override
  State<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends State<StressTestScreen> {
  static const int count = 8;
  final List<VideoPlayerController> _controllers = [];
  final List<VideoPlayerControlsWrapper> _wrappers = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  void _initializeVideoPlayers() async {
    for (int i = 0; i < count; i++) {
      final controller =
          initializeVideoPlayer(getSources()[i % getSources().length]);
      _controllers.add(controller);
      _wrappers.add(VideoPlayerControlsWrapper(controller));
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
    for (var wrapper in _wrappers) {
      wrapper.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = _controllers.map(
      (e) {
        final video = VideoControls(
          player: VideoPlayerControlsWrapper(e),
          autoDisposeControlsWrapper: false,
        );
        if (Theme.of(context).platform == TargetPlatform.android) {
          return video;
        }
        return Card(
          elevation: 8.0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: video,
        );
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : GridView.extent(
              maxCrossAxisExtent: 480.0,
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 16.0 / 9.0,
              children: children,
            ),
    );
  }
}
