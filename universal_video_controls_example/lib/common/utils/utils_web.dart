import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> initializeVideoPlayer(String source) async {
  late VideoPlayerController controller;

  if (source.startsWith('http') || source.startsWith('https')) {
    controller = VideoPlayerController.network(source);
  } else if (source.startsWith('asset')) {
    controller = VideoPlayerController.asset(source);
  } else {
    // Default to network for web if source type is not recognized
    controller = VideoPlayerController.network(source);
  }

  await controller.initialize();
  return controller;
}
