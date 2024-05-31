import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import '../common/sources/sources.dart';
import '../common/utils/utils.dart';

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
    _initializeVideoPlayer(sources[0]);
  }

  void _initializeVideoPlayer(String source) {
    _controller = VideoPlayerController.file(File(source))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
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
    for (int i = 0; i < sources.length; i++)
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
            _initializeVideoPlayer(sources[i]);
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
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.any);
              if (result?.files.isNotEmpty ?? false) {
                setState(() {
                  _controller.dispose();
                  _isInitialized = false;
                  _initializeVideoPlayer(result!.files.first.path!);
                });
              }
            },
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            heroTag: 'uri',
            tooltip: 'Open [Uri]',
            onPressed: () => showURIPicker(context, _controller),
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
