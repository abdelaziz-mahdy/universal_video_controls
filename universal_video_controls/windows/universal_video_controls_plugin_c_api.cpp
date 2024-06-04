#include "include/universal_video_controls/universal_video_controls_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "universal_video_controls_plugin.h"

void UniversalVideoControlsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  universal_video_controls::UniversalVideoControlsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
