//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <screen_retriever_linux/screen_retriever_linux_plugin.h>
#include <universal_video_controls/universal_video_controls_plugin.h>
#include <volume_controller/volume_controller_plugin.h>
#include <window_manager/window_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) screen_retriever_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenRetrieverLinuxPlugin");
  screen_retriever_linux_plugin_register_with_registrar(screen_retriever_linux_registrar);
  g_autoptr(FlPluginRegistrar) universal_video_controls_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UniversalVideoControlsPlugin");
  universal_video_controls_plugin_register_with_registrar(universal_video_controls_registrar);
  g_autoptr(FlPluginRegistrar) volume_controller_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "VolumeControllerPlugin");
  volume_controller_plugin_register_with_registrar(volume_controller_registrar);
  g_autoptr(FlPluginRegistrar) window_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowManagerPlugin");
  window_manager_plugin_register_with_registrar(window_manager_registrar);
}
