import 'package:elka/helper.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoApresepsi extends StatelessWidget {
  final int index;
  const VideoApresepsi(this.index);
  String getThumbnail(String url) {
    var id = YoutubePlayerController.convertUrlToId(url);
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
                    (context) =>
                        VideoPage(  prov.selectedBab!.youtubeIntroduction),
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
              color: Helper.lightenColor(Color.fromRGBO(53, 53, 53, 1), 0.7),
            ),
            child: Container(
              height: MediaQuery.of(context).size.width * 0.2,
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
                                prov.selectedBab!.youtubeIntroduction,
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
                                      prov.selectedBab!.youtubeIntroductionTitle,

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
