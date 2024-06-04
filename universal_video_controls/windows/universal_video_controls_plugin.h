#ifndef FLUTTER_PLUGIN_UNIVERSAL_VIDEO_CONTROLS_PLUGIN_H_
#define FLUTTER_PLUGIN_UNIVERSAL_VIDEO_CONTROLS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace universal_video_controls {

class UniversalVideoControlsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  UniversalVideoControlsPlugin();

  virtual ~UniversalVideoControlsPlugin();

  // Disallow copy and assign.
  UniversalVideoControlsPlugin(const UniversalVideoControlsPlugin&) = delete;
  UniversalVideoControlsPlugin& operator=(const UniversalVideoControlsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace universal_video_controls

#endif  // FLUTTER_PLUGIN_UNIVERSAL_VIDEO_CONTROLS_PLUGIN_H_
