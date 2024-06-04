import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'universal_video_controls_method_channel.dart';

abstract class UniversalVideoControlsPlatform extends PlatformInterface {
  /// Constructs a UniversalVideoControlsPlatform.
  UniversalVideoControlsPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniversalVideoControlsPlatform _instance = MethodChannelUniversalVideoControls();

  /// The default instance of [UniversalVideoControlsPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniversalVideoControls].
  static UniversalVideoControlsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniversalVideoControlsPlatform] when
  /// they register themselves.
  static set instance(UniversalVideoControlsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
