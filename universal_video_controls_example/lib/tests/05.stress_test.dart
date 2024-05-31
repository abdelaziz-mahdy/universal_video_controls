import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';
import '../common/utils/utils_import.dart';

class StressTestScreen extends StatefulWidget {
  const StressTestScreen({Key? key}) : super(key: key);

  @override
  State<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends State<StressTestScreen> {
  static const int count = 8;
  final List<VideoPlayerController> _controllers = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    prepareSources().then((_) {
      _initializeVideoPlayers();
    });
  }

  void _initializeVideoPlayers() async {
    for (int i = 0; i < count; i++) {
      final controller = await initializeVideoPlayer(getSources()[i % getSources().length]);
      _controllers.add(controller);
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

  @override
  Widget build(BuildContext context) {
    final children = _controllers.map(
      (e) {
        final video = VideoPlayer(e);
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
      body: GridView.extent(
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