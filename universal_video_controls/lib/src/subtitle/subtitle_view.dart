/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls/src/controls/methods/video_state.dart';

import '../../universal_players/abstract.dart';

/// {@template subtitle_view}
/// SubtitleView
/// ------------
///
/// [SubtitleView] widget is used to display the subtitles on top of the [Video].
/// {@endtemplate}
class SubtitleView extends StatefulWidget {
  /// The [AbstractPlayer] reference to control this [SubtitleView] output.
  final AbstractPlayer player;

  /// The configuration to be used for the subtitles.
  final SubtitleViewConfiguration configuration;

  /// {@macro subtitle_view}
  const SubtitleView({
    super.key,
    required this.player,
    required this.configuration,
  });

  @override
  SubtitleViewState createState() => SubtitleViewState();
}

class SubtitleViewState extends State<SubtitleView> {
  late List<String> subtitle = widget.player.state.subtitle;
  late TextStyle style = widget.configuration.style;
  late TextAlign textAlign = widget.configuration.textAlign;
  late EdgeInsets padding = widget.configuration.padding;
  late Duration duration = const Duration(milliseconds: 100);
  late AbstractPlayer _player = player(context);

  // The [StreamSubscription] to listen to the subtitle changes.
  StreamSubscription<List<String>>? subscription;

  // The reference width for calculating the visible text scale factor.
  static const kTextScaleFactorReferenceWidth = 1920.0;
  // The reference height for calculating the visible text scale factor.
  static const kTextScaleFactorReferenceHeight = 1080.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_player != player(context)) {
      subscription?.cancel();

      _player = player(context);
    }
    subscription = widget.player.stream.subtitle.listen((value) {
      if (mounted) {
        setState(() {
          subtitle = value;
        });
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  /// Sets the padding to be used for the subtitles.
  ///
  /// The [duration] argument may be specified to set the duration of the animation.
  void setPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    if (this.duration != duration) {
      setState(() {
        this.duration = duration;
      });
    }
    setState(() {
      this.padding = padding;
    });
  }

  /// {@macro subtitle_view}
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the visible text scale factor.
        final textScaleFactor = widget.configuration.textScaleFactor ??
            MediaQuery.of(context).textScaler.scale(sqrt(
                  ((constraints.maxWidth * constraints.maxHeight) /
                          (kTextScaleFactorReferenceWidth *
                              kTextScaleFactorReferenceHeight))
                      .clamp(0.0, 1.0),
                ));
        return Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            padding: padding,
            duration: duration,
            alignment: Alignment.bottomCenter,
            child: Text(
              [
                for (final line in subtitle)
                  if (line.trim().isNotEmpty) line.trim(),
              ].join('\n'),
              style: style,
              textAlign: textAlign,
              textScaler: TextScaler.linear(textScaleFactor),
            ),
          ),
        );
      },
    );
  }
}

/// {@template subtitle_view_configuration}
/// SubtitleViewConfiguration
/// -------------------------
///
/// Configurable options for customizing the [SubtitleView] behaviour.
/// {@endtemplate}
class SubtitleViewConfiguration {
  /// Whether the subtitles should be visible or not.
  final bool visible;

  /// The text style to be used for the subtitles.
  final TextStyle style;

  /// The text alignment to be used for the subtitles.
  final TextAlign textAlign;

  /// The text scale factor to be used for the subtitles.
  final double? textScaleFactor;

  /// The padding to be used for the subtitles.
  final EdgeInsets padding;

  /// {@macro subtitle_view_configuration}
  const SubtitleViewConfiguration({
    this.visible = true,
    this.style = const TextStyle(
      height: 1.4,
      fontSize: 32.0,
      letterSpacing: 0.0,
      wordSpacing: 0.0,
      color: Color(0xffffffff),
      fontWeight: FontWeight.normal,
      backgroundColor: Color(0xaa000000),
    ),
    this.textAlign = TextAlign.center,
    this.textScaleFactor,
    this.padding = const EdgeInsets.fromLTRB(
      16.0,
      0.0,
      16.0,
      24.0,
    ),
  });
}
