import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';

Future<void> paintFirstFrame(BuildContext context) async {
  final List<VideoPlayerController> _controllers = [];
  for (int i = 0; i < 5; i++) {
    final controller = await initializeVideoPlayer(getSources()[i % getSources().length]);
    _controllers.add(controller);
  }

  await Future.wait(_controllers.map((e) => e.initialize()));

  if (context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaintFirstFrameScreen(controllers: _controllers),
      ),
    );
  }

  for (final controller in _controllers) {
    await controller.dispose();
  }
}

class PaintFirstFrameScreen extends StatelessWidget {
  final List<VideoPlayerController> controllers;
  const PaintFirstFrameScreen({
    Key? key,
    required this.controllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: ListView.separated(
        itemCount: controllers.length,
        itemBuilder: (context, i) {
          final video = SizedBox(
            height: 256.0,
            child: AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: VideoPlayer(controllers[i]),
            ),
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
        separatorBuilder: (context, i) => const SizedBox(height: 16.0),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}