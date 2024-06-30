import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'universal_video_controls_platform_interface.dart';

/// An implementation of [UniversalVideoControlsPlatform] that uses method channels.
class MethodChannelUniversalVideoControls
    extends UniversalVideoControlsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('universal_video_controls');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
