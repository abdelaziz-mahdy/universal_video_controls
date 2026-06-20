import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_video_controls_example/common/sources/sources.dart';
import 'package:universal_video_controls_example/common/utils/utils.dart';
import 'package:universal_video_controls_example/common/utils/utils_import.dart';

class CustomAdaptiveControls extends StatefulWidget {
  const CustomAdaptiveControls({super.key});

  @override
  State<CustomAdaptiveControls> createState() => _CustomAdaptiveControlsState();
}

class _CustomAdaptiveControlsState extends State<CustomAdaptiveControls> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(getSources()[0]);
  }

  Future<void> _initializeVideoPlayer(String source) async {
    _controller = initializeVideoPlayer(source);
    setState(() {
      _isInitialized = true;
    });
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint(_controller.value.errorDescription);
      }
    });
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> get items => [
        for (int i = 0; i < getSources().length; i++)
          ListTile(
            title: Text(
              'Video $i',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _controller.dispose();
              _initializeVideoPlayer(getSources()[i]);
            },
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return // Wrap [Video] widget with [MaterialVideoControlsTheme].
        MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        // Modify theme options:
        buttonBarButtonSize: 24.0,
        buttonBarButtonColor: Colors.white,
        // Modify top button bar:
        topButtonBar: [
          const Spacer(),
          MaterialDesktopCustomButton(
            onPressed: () {
              debugPrint('Custom "Settings" button pressed.');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      fullscreen: const MaterialVideoControlsThemeData(
        // Modify theme options:
        displaySeekBar: false,
      ),
      child: // Wrap [Video] widget with [MaterialDesktopVideoControlsTheme].
          MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          // Modify theme options:
          seekBarThumbColor: Colors.blue,
          seekBarPositionColor: Colors.blue,
          toggleFullscreenOnDoublePress: false,
          // Modify top button bar:
          topButtonBar: [
            const Spacer(),
            MaterialDesktopCustomButton(
              onPressed: () {
                debugPrint('Custom "Settings" button pressed.');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          // Modify bottom button bar:
          bottomButtonBar: const [
            Spacer(),
            MaterialDesktopPlayOrPauseButton(),
            Spacer(),
            MaterialFullscreenButton()
          ],
        ),
        fullscreen: const MaterialDesktopVideoControlsThemeData(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Video Player'),
          ),
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'file',
                tooltip: 'Open [File]',
                onPressed: () => showFilePicker(context, (controller) {
                  setState(() {
                    _controller.dispose();
                    _isInitialized = false;
                    _controller = controller;
                    _isInitialized = true;
                  });
                }),
                child: const Icon(Icons.file_open),
              ),
              const SizedBox(width: 16.0),
              FloatingActionButton(
                heroTag: 'uri',
                tooltip: 'Open [Uri]',
                onPressed: () => showURIPicker(context, (controller) {
                  setState(() {
                    _controller.dispose();
                    _isInitialized = false;
                    _controller = controller;
                    _isInitialized = true;
                  });
                }),
                child: const Icon(Icons.link),
              ),
            ],
          ),
          body: !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : SizedBox.expand(
                  child: horizontal
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Card(
                                        elevation: 8.0,
                                        clipBehavior: Clip.antiAlias,
                                        margin: const EdgeInsets.all(32.0),
                                        child: VideoControls(
                                          player: VideoPlayerControlsWrapper(
                                              _controller),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32.0),
                                  ],
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1.0, thickness: 1.0),
                            Expanded(
                              flex: 1,
                              child: ListView(
                                children: items,
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            VideoControls(
                              player: VideoPlayerControlsWrapper(_controller),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width *
                                  9.0 /
                                  16.0,
                            ),
                            ...items,
                          ],
                        ),
                ),
        ),
      ),
    );
  }
}
