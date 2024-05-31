import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

Future<void> showFilePicker(
    BuildContext context, VideoPlayerController controller) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  if (result?.files.isNotEmpty ?? false) {
    final file = result!.files.first;
    if (file.path != null) {
      controller = VideoPlayerController.file(File(file.path!))
        ..initialize().then((_) {
          controller.play();
        });
    }
  }
}

Future<void> showURIPicker(
    BuildContext context, VideoPlayerController controller) async {
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
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      controller = VideoPlayerController.network(src.text)
                        ..initialize().then((_) {
                          controller.play();
                        });
                      Navigator.of(context).maybePop();
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
