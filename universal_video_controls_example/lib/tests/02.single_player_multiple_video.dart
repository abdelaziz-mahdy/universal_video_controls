import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';
import '../common/utils/utils_import.dart';

class SinglePlayerMultipleVideoScreen extends StatefulWidget {
  const SinglePlayerMultipleVideoScreen({Key? key}) : super(key: key);

  @override
  State<SinglePlayerMultipleVideoScreen> createState() => _SinglePlayerMultipleVideoScreenState();
}

class _SinglePlayerMultipleVideoScreenState extends State<SinglePlayerMultipleVideoScreen> {
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
          setState(() {
            _controller.dispose();
            _isInitialized = false;
            _initializeVideoPlayer(getSources()[i]);
          });
        },
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
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
      body: SizedBox.expand(
        child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 8.0,
                            color: Colors.black,
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.all(32.0),
                            child: _isInitialized
                                ? VideoPlayer(_controller)
                                : const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        const SizedBox(height: 32.0),
                      ],
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
                  if (_isInitialized)
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  ...items,
                ],
              ),
      ),
    );
  }
}