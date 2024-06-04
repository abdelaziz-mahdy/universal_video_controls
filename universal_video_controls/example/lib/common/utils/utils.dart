import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import 'utils_import.dart';

Future<void> showFilePicker(BuildContext context,
    void Function(VideoPlayerController) onControllerCreated) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  if (result?.files.isNotEmpty ?? false) {
    final file = result!.files.first;
    if (file.path != null) {
      final controller = initializeVideoPlayer(file.path!);
      onControllerCreated(controller);
      await controller.initialize();
      controller.play();
    }
  }
}

Future<void> showURIPicker(BuildContext context,
    void Function(VideoPlayerController) onControllerCreated) async {
  final key = GlobalKey<FormState>();
  final src = TextEditingController();
  await showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      alignment: Alignment.center,
      child: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: src,
                style: const TextStyle(fontSize: 14.0),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Video URI',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URI';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (key.currentState!.validate()) {
                      final controller = initializeVideoPlayer(src.text);
                      onControllerCreated(controller);

                      Navigator.of(context).maybePop();
                      await controller.initialize();
                      controller.play();
                    }
                  },
                  child: const Text('Play'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
