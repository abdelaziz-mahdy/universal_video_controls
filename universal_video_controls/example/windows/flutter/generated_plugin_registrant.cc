//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <screen_brightness_windows/screen_brightness_windows_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <universal_video_controls/universal_video_controls_plugin_c_api.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ScreenBrightnessWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenBrightnessWindowsPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  UniversalVideoControlsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UniversalVideoControlsPluginCApi"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
