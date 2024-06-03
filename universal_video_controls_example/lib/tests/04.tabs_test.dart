import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils_import.dart';

class TabsTest extends StatelessWidget {
  const TabsTest({super.key});

  static const int count = 5;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: count,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.8 * kToolbarHeight),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    labelStyle: const TextStyle(fontSize: 14.0),
                    unselectedLabelStyle: const TextStyle(fontSize: 14.0),
                    tabs: [
                      for (int i = 0; i < count; i++)
                        Tab(
                          text: 'Video $i',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            for (int i = 0; i < count; i++) TabView(i),
          ],
        ),
      ),
    );
  }
}

class TabView extends StatefulWidget {
  final int i;
  const TabView(this.i, {super.key});

  @override
  State<TabView> createState() => TabViewState();
}

class TabViewState extends State<TabView> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(getSources()[widget.i % getSources().length]);
  }

  void _initializeVideoPlayer(String source) async {
    _controller = initializeVideoPlayer(source);
    setState(() {
      _isInitialized = true;
    });
    await _controller.initialize();
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
    return VideoControls(
      player: VideoPlayerControlsWrapper(_controller),
      controls: NoVideoControls,
    );
  }
}
