import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';

class VideoControllerSetSizeScreen extends StatefulWidget {
  const VideoControllerSetSizeScreen({Key? key}) : super(key: key);

  @override
  State<VideoControllerSetSizeScreen> createState() =>
      _VideoControllerSetSizeScreenState();
}

class _VideoControllerSetSizeScreenState
    extends State<VideoControllerSetSizeScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    prepareSources().then((_) {
      _initializeVideoPlayer(getSources()[0]);
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          VideoPlayer(
            _controller,
            controls: NoVideoControls,
          ),
          Card(
            elevation: 8.0,
            margin: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 120.0,
              height: 64.0 * 6,
              child: ListView(
                children: [
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 2160 ~/ 1,
                      height: 2160,
                    ),
                    title: const Text(
                      '2160p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 1440 ~/ 1,
                      height: 1440,
                    ),
                    title: const Text(
                      '1440p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 1080 ~/ 1,
                      height: 1080,
                    ),
                    title: const Text(
                      '1080p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 720 ~/ 1,
                      height: 720,
                    ),
                    title: const Text(
                      '720p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 480 ~/ 1,
                      height: 480,
                    ),
                    title: const Text(
                      '480p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 360 ~/ 1,
                      height: 360,
                    ),
                    title: const Text(
                      '360p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 240 ~/ 1,
                      height: 240,
                    ),
                    title: const Text(
                      '240p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => _controller.setSize(
                      width: 16 / 9 * 144 ~/ 1,
                      height: 144,
                    ),
                    title: const Text(
                      '144p',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
