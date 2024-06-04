import 'package:video_player/video_player.dart';

VideoPlayerController initializeVideoPlayer(String source) {
  late VideoPlayerController controller;

  if (source.startsWith('http') || source.startsWith('https')) {
    controller = VideoPlayerController.networkUrl(Uri.parse(source));
  } else if (source.startsWith('asset')) {
    controller = VideoPlayerController.asset(source);
  } else {
    // Default to network for web if source type is not recognized
    controller = VideoPlayerController.networkUrl(Uri.parse(source));
  }

  return controller;
}
