import 'dart:developer';

import 'package:elka/helper.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoItem extends StatelessWidget {
  final bool isMaterial;
  final int index;
  const VideoItem(this.index, this.isMaterial);
  String getThumbnail(String url) {
    var id = YoutubePlayerController.convertUrlToId(url);
    log("https://i.ytimg.com/vi/$id/hqdefault.jpg");
    return "https://i.ytimg.com/vi/$id/hqdefault.jpg";
  }

  @override
  Widget build(BuildContext context) {
    var prov = context.watch<NavigationProvider>();

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => VideoPage(
                      isMaterial
                          ? prov.subabs[index].ytLinkMaterial
                          : prov.subabs[index].ytLinkExercise,
                    ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: prov.color.withOpacity(0.08),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
              color:
                  isMaterial
                      ? Helper.lightenColor(prov.color, 0.7)
                      : Helper.lightenColor(Color.fromRGBO(53, 53, 53, 1), 0.7),
            ),
            child: Container(
              height: MediaQuery.of(context).size.width * 0.06,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: prov.color.withOpacity(0.08),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              height: 30,
                              imageUrl: getThumbnail(
                                isMaterial
                                    ? prov.subabs[index].ytLinkMaterial
                                    : prov.subabs[index].ytLinkExercise,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    isMaterial
                                        ? prov.subabs[index].title
                                        : prov.subabs[index].exerciseTitle,
                                    maxLines: 3,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 12,
                                      overflow: TextOverflow.clip,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
