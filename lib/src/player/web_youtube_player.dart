import 'dart:html' show IFrameElement, window;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/enums/player_state.dart';
import 'package:youtube_player_flutter/src/utils/youtube_data.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_controller.dart';

class WebYoutubePlayer extends StatefulWidget {
  final Size size;

  WebYoutubePlayer({@required this.size});

  @override
  _WebYoutubePlayerState createState() => _WebYoutubePlayerState();
}

class _WebYoutubePlayerState extends State<WebYoutubePlayer> {
  IFrameElement iFrame;
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'youtube_player_flutter',
      (int viewId) {
        iFrame = IFrameElement()
          ..srcdoc = player
          ..height = widget.size.height.toString()
          ..width = widget.size.width.toString()
          ..style.border = 'none';
        _controller.updateValue(_controller.value.copyWith(currentIframe: iFrame));
        return iFrame;
      },
    );
    window.onMessage.listen(
      (event) {
        YoutubeData data = YoutubeData.fromJsonString(event.data);
        if (checkNull(data.ready)) {
          _controller.updateValue(
            _controller.value.copyWith(isReady: true, isEvaluationReady: true),
          );
        }
        if (checkNull(data.playbackQuality)) {
          _controller.updateValue(
            _controller.value.copyWith(
              playbackQuality: data.playbackQuality,
            ),
          );
        }
        if (checkNull(data.playerState)) {
          switch (data.playerState) {
            case -1:
              _controller.updateValue(
                _controller.value.copyWith(
                  playerState: PlayerState.unStarted,
                  isLoaded: true,
                ),
              );
              break;
            case 0:
              _controller.updateValue(
                _controller.value.copyWith(playerState: PlayerState.ended),
              );
              break;
            case 1:
              _controller.updateValue(
                _controller.value.copyWith(
                  playerState: PlayerState.playing,
                  isPlaying: true,
                  hasPlayed: true,
                  errorCode: 0,
                ),
              );
              break;
            case 2:
              _controller.updateValue(
                _controller.value.copyWith(
                  playerState: PlayerState.paused,
                  isPlaying: false,
                ),
              );
              break;
            case 3:
              _controller.updateValue(
                _controller.value.copyWith(playerState: PlayerState.buffering),
              );
              break;
            case 5:
              _controller.updateValue(
                _controller.value.copyWith(playerState: PlayerState.cued),
              );
              break;
            default:
              throw Exception("Invalid player state obtained.");
          }
        }
        if (checkNull(data.currentTime)) {
          _controller.updateValue(
            _controller.value.copyWith(
              position: Duration(milliseconds: (data.currentTime * 1000).floor()),
            ),
          );
        }
        if (checkNull(data.loadedFraction)) {
          _controller.updateValue(
            _controller.value.copyWith(
              buffered: data.loadedFraction,
            ),
          );
        }
        if (checkNull(data.duration)) {
          _controller.updateValue(
            _controller.value.copyWith(
              duration: Duration(milliseconds: (data.duration * 1000).floor()),
            ),
          );
        }
        if (checkNull(data.title)) {
          _controller.updateValue(
            _controller.value.copyWith(title: data.title),
          );
        }
        if (checkNull(data.author)) {
          _controller.updateValue(
            _controller.value.copyWith(author: data.author),
          );
        }
      },
    );
  }

  bool checkNull(Object item) => item != null;

  @override
  Widget build(BuildContext context) {
    _controller = YoutubePlayerController.of(context);
    return ListView(
      children: <Widget>[
        SizedBox.fromSize(
          size: widget.size,
          child: HtmlElementView(
            viewType: 'youtube_player_flutter',
          ),
        ),
        RaisedButton(
          color: Colors.green,
          child: Text('PAUSE'),
          onPressed: () {
            _controller.pause();
          },
        ),
      ],
    );
  }

  String get player => '''
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            var timerId;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    videoId: '${_controller.initialVideoId}',
                    width: '${widget.size.width}',
                    height: '${widget.size.height}',
                    playerVars: {
                        'controls': ${boolean(_controller.flags.showControls)},
                        'playsinline': 1,
                        'enablejsapi': 1,
                        'fs': 1,
                        'rel': 0,
                        'showinfo': 0,
                        'iv_load_policy': 3,
                        'modestbranding': 1,
                        'cc_load_policy': ${boolean(_controller.flags.enableCaption)},
                        'cc_lang_pref': '${_controller.flags.captionLanguage}',
                        'autoplay': ${boolean(_controller.flags.autoPlay)},
                    },
                    events: {
                        onReady: (event) => sendMessage({ 'ready': true }),
                        onStateChange: (event) => sendPlayerStateChange(event.data),
                        onPlaybackQualityChange: (event) => sendMessage({ 'playbackQualityChange': event.data }),
                        onPlaybackRateChange: (event) => sendMessage({ 'playbackRateChange': event.data }),
                        onError: (error) => sendMessage({ 'error': event.data }),
                    },
                });
            }
            
            function sendMessage(message) {
                window.parent.postMessage(JSON.stringify(message), '*');
            }
            
            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                sendMessage({ 'playerState': playerState });
                if (playerState == 1) {
                    startSendCurrentTimeInterval();
                    sendMessage({ 
                        'duration': player.getDuration() , 
                        'title': player.getVideoData().title,
                        'author': player.getVideoData().author,
                    });
                }
            }
            
            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                    sendMessage({
                        'currentTime': player.getCurrentTime(),
                        'loadedFraction': player.getVideoLoadedFraction()
                    });
                }, 100);
            }
            
            function toggleFullscreen() {
                var isInFullScreen = (document.fullscreenElement && document.fullscreenElement !== null) ||
                    (document.webkitFullscreenElement && document.webkitFullscreenElement !== null) ||
                    (document.mozFullScreenElement && document.mozFullScreenElement !== null) ||
                    (document.msFullscreenElement && document.msFullscreenElement !== null);
                var docElm = document.documentElement;
                if (!isInFullScreen) {
                    if (docElm.requestFullscreen) {
                        docElm.requestFullscreen();
                    } else if (docElm.mozRequestFullScreen) {
                        docElm.mozRequestFullScreen();
                    } else if (docElm.webkitRequestFullScreen) {
                        docElm.webkitRequestFullScreen();
                    } else if (docElm.msRequestFullscreen) {
                        docElm.msRequestFullscreen();
                    }
                } else {
                    if (document.exitFullscreen) {
                        document.exitFullscreen();
                    } else if (document.webkitExitFullscreen) {
                        document.webkitExitFullscreen();
                    } else if (document.mozCancelFullScreen) {
                        document.mozCancelFullScreen();
                    } else if (document.msExitFullscreen) {
                        document.msExitFullscreen();
                    }
                }
            }
            
            window.addEventListener('message', (event) => {
                if(event.data.includes('methodName')){
                  try {
                    var data = JSON.parse(event.data);
                    switch (data.methodName) {
                        case 'play': player.playVideo(); break;
                        case 'pause': player.pauseVideo(); break;
                        case 'mute': player.mute(); break;
                        case 'unMute': player.unMute(); break;
                        case 'loadById': player.loadVideoById(data.arg1, data.arg2); break;
                        case 'cueById': player.cueVideoById(data.arg1, data.arg2); break;
                        case 'setVolume': player.setVolume(data.arg1); break;
                        case 'seekTo': player.seekTo(data.arg1, data.arg2); break;
                        case 'setSize': player.setSize(data.arg1, data.arg2); break;
                        case 'setPlaybackRate': player.setPlaybackRate(data.arg1); break;
                        case 'toggleFullScreen': toggleFullscreen(); break;
                        default: console.error('No implementation found for the method name: ' + data.methodName);
                    }
                } catch (e) {}
                }
            }, false);
        </script>
    ''';

  String boolean(bool value) => value ? "'1'" : "'0'";
}
