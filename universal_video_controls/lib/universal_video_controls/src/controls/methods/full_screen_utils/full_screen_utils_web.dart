// --------------------------------------------------

import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart';

/// Makes the native window enter fullscreen.
Future<void> defaultEnterNativeFullscreen() async {
  try {
    await document.documentElement?.requestFullscreen().toDart;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

/// Makes the native window exit fullscreen.
Future<void> defaultExitNativeFullscreen() async {
  try {
    await document.exitFullscreen().toDart;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

// --------------------------------------------------
