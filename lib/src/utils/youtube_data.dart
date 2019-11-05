import 'dart:convert';

class YoutubeData {
  final bool ready;
  final int playerState;
  final String playbackQuality;
  final double duration;
  final double currentTime;
  final double loadedFraction;
  final int error;
  final String title;
  final String author;

  YoutubeData({
    this.ready,
    this.playerState,
    this.playbackQuality,
    this.duration,
    this.currentTime,
    this.loadedFraction,
    this.error,
    this.title,
    this.author,
  });

  factory YoutubeData.fromJsonString(String jsonString) {
    try {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return YoutubeData(
        ready: json["ready"],
        playerState: json["playerState"],
        playbackQuality: json["playbackQuality"],
        duration: json["duration"],
        currentTime: json["currentTime"],
        loadedFraction: json["loadedFraction"],
        error: json["error"],
        title: json["title"],
        author: json["author"],
      );
    } on FormatException catch (e) {
      print(e.message);
      return YoutubeData();
    }
  }
}
