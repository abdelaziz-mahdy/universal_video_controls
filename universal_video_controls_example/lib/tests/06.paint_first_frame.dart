import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils_import.dart';

Future<void> paintFirstFrame(BuildContext context) async {
  final List<VideoPlayerController> controllers = [];
  for (int i = 0; i < 5; i++) {
    final controller =
        initializeVideoPlayer(getSources()[i % getSources().length]);
    controllers.add(controller);
    controller.initialize();
  }

  await Future.wait(controllers.map((e) => e.initialize()));

  if (context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaintFirstFrameScreen(controllers: controllers),
      ),
    );
  }

  for (final controller in controllers) {
    await controller.dispose();
  }
}

class PaintFirstFrameScreen extends StatelessWidget {
  final List<VideoPlayerController> controllers;
  const PaintFirstFrameScreen({
    super.key,
    required this.controllers,
  });

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
                child: VideoControls(
                  player: VideoPlayerControlsWrapper(controllers[i]),
                )),
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
