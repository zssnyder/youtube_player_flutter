// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines player flags for [YoutubePlayer].
class YoutubePlayerFlags {
  /// if set to false, hides the controls.
  ///
  /// Default is true.
  final bool showControls;

  /// Define whether to auto play the video after initialization or not.
  ///
  /// Default is true.
  final bool autoPlay;

  /// Mutes the player initially
  ///
  /// Default is false.
  final bool mute;

  /// if true, Live Playback controls will be shown instead of default one.
  ///
  /// Default is false.
  final bool isLive;

  /// If true, hides the YouTube player annotation. Default is false.
  ///
  /// Forcing annotation to hide is a hacky way. Although this shouldn't be against Youtube TOS, the author doesn't guarantee
  /// and won't be responsible for any casualties regarding the YouTube TOS violation.
  ///
  /// It's hidden by default on iOS. Changing this flag will have no effect on iOS.
  final bool forceHideAnnotation;

  /// Hides thumbnail if false.
  ///
  /// Default is true.
  final bool showThumbnail;

  /// Enables seeking video position when dragging horizontally.
  ///
  /// Default is true.
  final bool enableDragSeek;

  /// Enabling this causes the player to play the video again and again.
  ///
  /// Default is false.
  final bool loop;

  /// Enabling causes closed captions to be shown by default.
  ///
  /// Default is true.
  final bool enableCaption;

  /// Specifies the default language that the player will use to display captions. Set the parameter's value to an [ISO 639-1 two-letter language code](http://www.loc.gov/standards/iso639-2/php/code_list.php).
  ///
  /// Default is `en`.
  final String captionLanguage;

  /// Causes the player to begin playing the video at the given number of seconds from the start of the video.
  final Duration start;

  /// Specifies the time, measured in seconds from the start of the video,
  /// when the player should stop playing the video.
  ///
  /// The time is measured from the beginning of the video.
  final Duration end;

  const YoutubePlayerFlags({
    this.showControls = true,
    this.autoPlay = true,
    this.mute = false,
    this.isLive = false,
    this.forceHideAnnotation = true,
    this.showThumbnail = true,
    this.enableDragSeek = true,
    this.enableCaption = true,
    this.captionLanguage = 'en',
    this.loop = false,
    this.start,
    this.end,
  });

  YoutubePlayerFlags copyWith({
    bool hideControls,
    bool autoPlay,
    bool mute,
    bool showVideoProgressIndicator,
    bool isLive,
    bool forceHideAnnotation,
    bool hideThumbnail,
    bool disableDragSeek,
    bool loop,
    bool enableCaption,
    String captionLanguage,
    Duration start,
    Duration end,
  }) {
    return YoutubePlayerFlags(
      autoPlay: autoPlay ?? this.autoPlay,
      captionLanguage: captionLanguage ?? this.captionLanguage,
      enableDragSeek: disableDragSeek ?? this.enableDragSeek,
      enableCaption: enableCaption ?? this.enableCaption,
      end: end ?? this.end,
      forceHideAnnotation: forceHideAnnotation ?? this.forceHideAnnotation,
      showControls: hideControls ?? this.showControls,
      showThumbnail: hideThumbnail ?? this.showThumbnail,
      isLive: isLive ?? this.isLive,
      loop: loop ?? this.loop,
      mute: mute ?? this.mute,
      start: start ?? this.start,
    );
  }
}
