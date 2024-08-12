/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_video_controls/src/utils/dispose_safe_notifer.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls/universal_video_controls/src/controls/methods/video_state.dart';

import '../../universal_players/abstract.dart';
import '../../universal_video_controls.dart' as universal_video_controls;

import '../utils/wakelock.dart';

/// {@template video}
///
/// Video
/// -----
/// [Video] widget is used to display video output.
///
/// Use [VideoController] to initialize & handle the video rendering.
///
/// **Example:**
///
/// ```dart
/// class MyScreen extends StatefulWidget {
///   const MyScreen({Key? key}) : super(key: key);
///   @override
///   State<MyScreen> createState() => MyScreenState();
/// }
///
/// class MyScreenState extends State<MyScreen> {
///   late final player = Player();
///   late final controller = VideoController(player);
///
///   @override
///   void initState() {
///     super.initState();
///     player.open(Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));
///   }
///
///   @override
///   void dispose() {
///     player.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Video(
///         controller: controller,
///       ),
///     );
///   }
/// }
/// ```
///
/// {@endtemplate}
class VideoControls extends StatefulWidget {
  /// The [AbstractPlayer] reference to control this [VideoControls] output.
  final AbstractPlayer player;

  /// Width of this viewport.
  final double? width;

  /// Height of this viewport.
  final double? height;

  /// Fit of the viewport.
  final BoxFit fit;

  /// Background color to fill the video background.
  final Color fill;

  /// Alignment of the viewport.
  final Alignment alignment;

  /// Preferred aspect ratio of the viewport.
  final double? aspectRatio;

  /// Filter quality of the [Texture] widget displaying the video output.
  final FilterQuality filterQuality;

  /// Video controls builder.
  final VideoControlsBuilder? controls;

  /// Whether to acquire wake lock while playing the video.
  final bool wakelock;

  /// Whether to pause the video when application enters background mode.
  final bool pauseUponEnteringBackgroundMode;

  /// Whether to resume the video when application enters foreground mode.
  ///
  /// This attribute is only applicable if [pauseUponEnteringBackgroundMode] is `true`.
  ///
  final bool resumeUponEnteringForegroundMode;

  /// The configuration for subtitles e.g. [TextStyle] & padding etc.
  final SubtitleViewConfiguration subtitleViewConfiguration;

  /// The callback invoked when the [VideoControls] enters fullscreen.
  final Future<void> Function() onEnterFullscreen;

  /// The callback invoked when the [VideoControls] exits fullscreen.
  final Future<void> Function() onExitFullscreen;

  /// Whether to dispose the controls wrapper on the widget dispose or not
  /// Which the [AbstractPlayer]
  /// Default: is true to save resources
  final bool autoDisposeControlsWrapper;

  /// {@macro video}
  const VideoControls(
      {super.key,
      required this.player,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.fill = const Color(0xFF000000),
      this.alignment = Alignment.center,
      this.aspectRatio,
      this.filterQuality = FilterQuality.low,
      this.controls = universal_video_controls.AdaptiveVideoControls,
      this.wakelock = true,
      this.pauseUponEnteringBackgroundMode = true,
      this.resumeUponEnteringForegroundMode = false,
      this.subtitleViewConfiguration = const SubtitleViewConfiguration(),
      this.onEnterFullscreen = defaultEnterNativeFullscreen,
      this.onExitFullscreen = defaultExitNativeFullscreen,
      this.autoDisposeControlsWrapper = true});

  @override
  State<VideoControls> createState() => VideoControlsState();
}

class VideoControlsState extends State<VideoControls>
    with WidgetsBindingObserver {
  late final _contextNotifier = DisposeSafeNotifier<BuildContext?>(null);
  late ValueNotifier<VideoViewParameters> _videoViewParametersNotifier;
  late bool _disposeNotifiers;
  final _subtitleViewKey = GlobalKey<SubtitleViewState>();
  final _wakelock = Wakelock();
  final _subscriptions = <StreamSubscription>[];
  late int? _width = widget.player.state.width;
  late int? _height = widget.player.state.height;
  late bool _visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;
  ValueKey _key = const ValueKey(true);
  Function({bool autoHide})? _showControlsCall;
  Function? _hideControlsCall;
  bool _pauseDueToPauseUponEnteringBackgroundMode = false;
  // Public API:
  bool isFullscreen() {
    return universal_video_controls.isFullscreen(_contextNotifier.value!);
  }

  Future<void> enterFullscreen() {
    return universal_video_controls.enterFullscreen(_contextNotifier.value!);
  }

  Future<void> exitFullscreen() {
    return universal_video_controls.exitFullscreen(_contextNotifier.value!);
  }

  Future<void> toggleFullscreen() {
    return universal_video_controls.toggleFullscreen(_contextNotifier.value!);
  }

  void setSubtitleViewPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _subtitleViewKey.currentState?.setPadding(
      padding,
      duration: duration,
    );
  }

  void update({
    double? width,
    double? height,
    BoxFit? fit,
    Color? fill,
    Alignment? alignment,
    double? aspectRatio,
    FilterQuality? filterQuality,
    VideoControlsBuilder? controls,
    SubtitleViewConfiguration? subtitleViewConfiguration,
    AbstractPlayer? player,
  }) {
    _videoViewParametersNotifier.value = _videoViewParametersNotifier.value
        .copyWith(
            width: width,
            height: height,
            fit: fit,
            fill: fill,
            alignment: alignment,
            aspectRatio: aspectRatio,
            filterQuality: filterQuality,
            controls: controls,
            subtitleViewConfiguration: subtitleViewConfiguration,
            player: player);
  }

  /// force show the controls
  /// [hideControls] need to called to hide controls
  void showControls({bool autoHide = false}) {
    if (_showControlsCall != null) {
      _showControlsCall!(autoHide: autoHide);
    } else {
      if (kDebugMode) {
        print("_showControlsCall callback not found");
      }
    }
  }

  /// force hide the controls
  /// This need to be called if [showControls] with auto hide being false
  void hideControls() {
    if (_hideControlsCall != null) {
      _hideControlsCall!();
    } else {
      if (kDebugMode) {
        print("_hideControlsCall callback not found");
      }
    }
  }

  /// Internal method dont use it in your app (exposed for internal use only),
  /// This method will set the logic for configuring the any settings in the underline controls
  void setShowControlsLogic(Function({bool autoHide}) showControlsCall) {
    _showControlsCall = showControlsCall;
  }

  /// Internal method dont use it in your app (exposed for internal use only),
  /// This method will set the logic for configuring the any settings in the underline controls
  void setHideControlsLogic(Function() hideControlsCall) {
    _hideControlsCall = hideControlsCall;
  }

  @override
  void didUpdateWidget(covariant VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentParams = _videoViewParametersNotifier.value;

    final newParams = currentParams.copyWith(
      width:
          widget.width != oldWidget.width ? widget.width : currentParams.width,
      height: widget.height != oldWidget.height
          ? widget.height
          : currentParams.height,
      fit: widget.fit != oldWidget.fit ? widget.fit : currentParams.fit,
      fill: widget.fill != oldWidget.fill ? widget.fill : currentParams.fill,
      alignment: widget.alignment != oldWidget.alignment
          ? widget.alignment
          : currentParams.alignment,
      aspectRatio: widget.aspectRatio != oldWidget.aspectRatio
          ? widget.aspectRatio
          : currentParams.aspectRatio,
      filterQuality: widget.filterQuality != oldWidget.filterQuality
          ? widget.filterQuality
          : currentParams.filterQuality,
      controls: widget.controls != oldWidget.controls
          ? widget.controls
          : currentParams.controls,
      subtitleViewConfiguration: widget.subtitleViewConfiguration !=
              oldWidget.subtitleViewConfiguration
          ? widget.subtitleViewConfiguration
          : currentParams.subtitleViewConfiguration,
      player: widget.player != oldWidget.player
          ? widget.player
          : currentParams.player,
    );

    if (newParams != currentParams) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _videoViewParametersNotifier.value = newParams;
      });
      if (widget.player != oldWidget.player) {
        cancelSubscriptions();
        subscribeToEvents();
      }
    }
  }

  @override
  void didChangeDependencies() {
    _videoViewParametersNotifier =
        universal_video_controls.VideoStateInheritedWidget.maybeOf(
              context,
            )?.videoViewParametersNotifier ??
            ValueNotifier<VideoViewParameters>(
              VideoViewParameters(
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                  fill: widget.fill,
                  alignment: widget.alignment,
                  aspectRatio: widget.aspectRatio,
                  filterQuality: widget.filterQuality,
                  controls: widget.controls,
                  subtitleViewConfiguration: widget.subtitleViewConfiguration,
                  player: widget.player),
            );

    _disposeNotifiers =
        universal_video_controls.VideoStateInheritedWidget.maybeOf(
              context,
            )?.disposeNotifiers ??
            true;
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.pauseUponEnteringBackgroundMode) {
      if ([
        AppLifecycleState.paused,
        AppLifecycleState.detached,
      ].contains(state)) {
        if (_videoViewParametersNotifier.value.player.state.playing) {
          _pauseDueToPauseUponEnteringBackgroundMode = true;
          _videoViewParametersNotifier.value.player.pause();
        }
      } else {
        if (widget.resumeUponEnteringForegroundMode &&
            _pauseDueToPauseUponEnteringBackgroundMode) {
          _pauseDueToPauseUponEnteringBackgroundMode = false;
          _videoViewParametersNotifier.value.player.play();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    subscribeToEvents();
  }

  void subscribeToEvents() {
    // --------------------------------------------------
    // Do not show the video frame until width & height are available.
    // Since [ValueNotifier<Rect?>] inside [VideoController] only gets updated by the render loop (i.e. it will not fire when video's width & height are not available etc.), it's important to handle this separately here.
    _subscriptions.addAll(
      [
        widget.player.stream.width.listen(
          (value) {
            _width = value;
            final visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;
            if (_visible != visible) {
              setState(() {
                _visible = visible;
              });
            }
          },
        ),
        widget.player.stream.height.listen(
          (value) {
            _height = value;
            final visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;
            if (_visible != visible) {
              setState(() {
                _visible = visible;
              });
            }
          },
        ),
      ],
    );
    // --------------------------------------------------
    if (widget.wakelock) {
      if (widget.player.state.playing) {
        _wakelock.enable();
      }
      _subscriptions.add(
        widget.player.stream.playing.listen(
          (value) {
            if (value) {
              _wakelock.enable();
            } else {
              _wakelock.disable();
            }
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wakelock.disable();

    cancelSubscriptions();

    if (_disposeNotifiers) {
      if (widget.autoDisposeControlsWrapper) {
        _videoViewParametersNotifier.value.player.dispose();
      }
      _videoViewParametersNotifier.dispose();
      _contextNotifier.dispose();
      VideoStateInheritedWidgetContextNotifierState.fallback.remove(this);
    }

    super.dispose();
  }

  void cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void refreshView() {
    if (kIsWeb) {
      setState(() {
        _key = ValueKey(!_key.value);
      });
      // this is intended (to call the function after two frames)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (player(_contextNotifier.value!).state.playing) {
            player(_contextNotifier.value!).play();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return universal_video_controls.VideoStateInheritedWidget(
      state: this,
      contextNotifier: _contextNotifier,
      videoViewParametersNotifier: _videoViewParametersNotifier,
      child: ValueListenableBuilder<VideoViewParameters>(
        valueListenable: _videoViewParametersNotifier,
        builder: (context, videoViewParameters, _) {
          return Container(
              clipBehavior: Clip.none,
              width: videoViewParameters.width,
              height: videoViewParameters.height,
              color: videoViewParameters.fill,
              child: LayoutBuilder(builder: (context, rect) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: FittedBox(
                          fit: videoViewParameters.fit,
                          alignment: videoViewParameters.alignment,
                          child: StreamBuilder<int?>(
                              stream: videoViewParameters.player.stream.width,
                              builder: (context, snapshot) {
                                return SizedBox(
                                  width:
                                      player(context).state.width?.toDouble() ??
                                          rect.maxWidth,
                                  height: player(context)
                                          .state
                                          .height
                                          ?.toDouble() ??
                                      rect.maxHeight,
                                  child: Stack(
                                    children: [
                                      const SizedBox(),
                                      Positioned.fill(
                                          key: _key,
                                          child: player(context).videoWidget()),
                                      // // Keep the |Texture| hidden before the first frame renders. In native implementation, if no default frame size is passed (through VideoController), a starting 1 pixel sized texture/surface is created to initialize the render context & check for H/W support.
                                      // // This is then resized based on the video dimensions & accordingly texture ID, texture, EGLDisplay, EGLSurface etc. (depending upon platform) are also changed. Just don't show that 1 pixel texture to the UI.
                                      // // NOTE: Unmounting |Texture| causes the |MarkTextureFrameAvailable| to not do anything on GNU/Linux.
                                      // if (rect.width <= 1.0 && rect.height <= 1.0)
                                      //   Positioned.fill(
                                      //     child: Container(
                                      //       color: videoViewParameters.fill,
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                );
                              })),
                    ),
                    if (videoViewParameters.subtitleViewConfiguration.visible)
                      Positioned.fill(
                        child: SubtitleView(
                          player: videoViewParameters.player,
                          key: _subtitleViewKey,
                          configuration:
                              videoViewParameters.subtitleViewConfiguration,
                        ),
                      ),
                    if (videoViewParameters.controls != null)
                      Positioned.fill(
                        child: videoViewParameters.controls!.call(this),
                      ),
                  ],
                );
              }));
        },
      ),
    );
  }
}

typedef VideoControlsBuilder = Widget Function(VideoControlsState state);
