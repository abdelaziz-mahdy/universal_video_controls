import 'dart:io';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> initializeVideoPlayer(String source) async {
  late VideoPlayerController controller;

  if (source.startsWith('http') || source.startsWith('https')) {
    controller = VideoPlayerController.network(source);
  } else if (source.startsWith('asset')) {
    controller = VideoPlayerController.asset(source);
  } else {
    controller = VideoPlayerController.file(File(source));
  }

  await controller.initialize();
  return controller;
}
