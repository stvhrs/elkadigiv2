// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'package:elka/main.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPage extends StatefulWidget {
  final String link;

  const VideoPage(this.link, {super.key});

  @override
  VideoPageState createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;
  bool _isLoading = true;
  bool _isFullScreen = false;
  double _aspectRatio = 16 / 9;
  bool auto = true;
  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _saveScore(1);
  }

  Future<void> _initializePlayer() async {
    SystemUiOverlayStyle(statusBarColor: Colors.black);
    try {
      // Check if it's a shorts video
      final isShort = widget.link.contains("shorts");
      _controller = YoutubePlayerController(
        params: YoutubePlayerParams(
          showFullscreenButton: true,
          strictRelatedVideos: true,
          showVideoAnnotations: false,
          enableJavaScript: false,

          color: 'red',
        ),
      );
      _controller.loadVideoById(
        videoId: YoutubePlayerController.convertUrlToId(widget.link)!,
      );
      _aspectRatio = isShort ? 9 / 16 : 16 / 9;
      if (!isShort) {
        _controller!.enterFullScreen(lock: false);
      }
      _controller.setFullScreenListener((isFullScreen) {
        if (mounted) {
          setState(() {
            _isFullScreen = isFullScreen;
          });
        }
      });
      if (!isShort) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.enterFullScreen();
        });
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error initializing YouTube player: $e');
    }
  }

  Future<void> _saveScore(double score) async {
    final roundedScore = score.floor();
    await box.put(widget.link, roundedScore);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NavigationProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _controller.exitFullScreen();
          return false;
        }
        return true;
      },
      child:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: prov.color))
              : YoutubePlayerScaffold(
                autoFullScreen: true,
                backgroundColor: Colors.white,
                enableFullScreenOnVerticalDrag: false,
                // Changed from YoutubePlayerControllerProvider
                controller: _controller,
                aspectRatio: _aspectRatio,
                builder: (context, player) {
                  // if (auto == true && _aspectRatio == 16 / 9) {
                  //   _controller!.toggleFullScreen();
                  //   auto = false;
                  //   log(" fullsceen");
                  // }
                  return Scaffold(
                    appBar: AppBar(),
                    backgroundColor: Colors.white,
                    body: ListView(
                      children: [
                        SizedBox(
                          child:
                              defaultTargetPlatform == TargetPlatform.windows ||
                                      defaultTargetPlatform ==
                                          TargetPlatform.macOS
                                  ? Transform.scale(scale: 0.8,alignment: Alignment.topCenter,
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: player,
                                    ),
                                  )
                                  : AspectRatio(
                                    aspectRatio: _aspectRatio,
                                    child: player,
                                  ),
                        ),

                        if (!widget.link.contains("shorts"))
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.topCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () => _controller.enterFullScreen(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Fullscreen ",
                                          style: TextStyle(
                                            color: prov.color,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          _isFullScreen
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen,
                                          color: prov.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
