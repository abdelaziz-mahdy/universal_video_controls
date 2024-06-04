import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tests/01.single_player_single_video.dart';
import 'tests/02.tabs_test.dart';
import 'tests/03.stress_test.dart';
import 'tests/04.paint_first_frame.dart';
import 'tests/05.seamless.dart';
import 'tests/06.programmatic_fullscreen.dart';
import 'tests/07.video_view_parameters.dart';

import 'common/sources/sources.dart';
import 'tests/08.custom_mobile_controls.dart';
import 'tests/09.custom_desktop_controls.dart';
import 'tests/10.custom_adaptive_controls.dart';
import 'tests/11.full_screen_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  runApp(const MyApp(DownloadingScreen()));
  await prepareSources();
  runApp(const MyApp(PrimaryScreen()));
}

class MyApp extends StatelessWidget {
  final Widget child;
  const MyApp(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: child,
    );
  }
}

class PrimaryScreen extends StatelessWidget {
  const PrimaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:universal_video_controls'),
        actions: const [
          SizedBox(width: 16.0),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'single_player_single_video.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SinglePlayerSingleVideoScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'tabs_test.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TabsTest(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'stress_test.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StressTestScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'paint_first_frame.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              paintFirstFrame(context);
            },
          ),
          ListTile(
            title: const Text(
              'seamless.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Seamless(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'programmatic_fullscreen.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProgrammaticFullscreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'video_view_parameters.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoViewParametersScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'custom_mobile_controls.dart',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomMobileControls(),
                ),
              );
            },
          ),
          ListTile(
              title: const Text(
                'custom_desktop_controls.dart',
                style: TextStyle(fontSize: 14.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CustomDesktopControls(),
                ));
              }),
          ListTile(
              title: const Text(
                'custom_adaptive_controls.dart',
                style: TextStyle(fontSize: 14.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CustomAdaptiveControls(),
                ));
              }),
          ListTile(
              title: const Text(
                'full_screen_player.dart',
                style: TextStyle(fontSize: 14.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FullScreenPlayer(),
                ));
              }),
        ],
      ),
    );
  }
}

class DownloadingScreen extends StatelessWidget {
  const DownloadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:universal_video_controls'),
      ),
      body: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: progress,
          child: const CircularProgressIndicator(),
          builder: (context, progress, child) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              child!,
              const SizedBox(height: 16.0),
              Text(
                progress,
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
