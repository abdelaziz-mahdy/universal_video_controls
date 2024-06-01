import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';
import '../common/utils/utils_import.dart';

class Seamless extends StatefulWidget {
  const Seamless({Key? key}) : super(key: key);

  @override
  State<Seamless> createState() => _SeamlessState();
}

class _SeamlessState extends State<Seamless> {
  final pageController = PageController(initialPage: 0);
  final early = HashSet<int>();
  final players = HashMap<int, VideoPlayerController>();

  @override
  void initState() {
    super.initState();
      Future.wait([createPlayer(0), createPlayer(1)]).then((_) {
        players[0]?.play();
      });
  }

  @override
  void dispose() {
    for (final player in players.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> createPlayer(int page) async {
    final controller = await initializeVideoPlayer(
        getSources()[Random().nextInt(getSources().length)]);
    players[page] = controller;

    if (early.contains(page)) {
      early.remove(page);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Stack(
        children: [
          PageView.builder(
            onPageChanged: (i) {
              players[i]?.play();

              players.removeWhere((page, player) {
                final remove = ![i, i - 1, i + 1].contains(page);
                if (remove) {
                  player.dispose();
                }
                return remove;
              });

              players.forEach((key, value) {
                if (key != i) {
                  value.pause();
                  value.seekTo(Duration.zero);
                }
              });

              if (!players.containsKey(i)) createPlayer(i);
              if (!players.containsKey(i + 1)) createPlayer(i + 1);
              if (!players.containsKey(i - 1)) createPlayer(i - 1);

              debugPrint('players: ${players.keys}');
            },
            itemBuilder: (context, i) {
              final controller = players[i];
              if (controller == null) {
                early.add(i);
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xffffffff)),
                );
              }
              return VideoControls(
                player: VideoPlayerControlsWrapper(controller),
              );
            },
            controller: pageController,
            scrollDirection: Axis.vertical,
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.black38,
                    child: InkWell(
                      onTap: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.expand_less,
                          size: 28.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 8),
                Expanded(
                  child: Material(
                    color: Colors.black38,
                    child: InkWell(
                      onTap: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.expand_more,
                          size: 28.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
