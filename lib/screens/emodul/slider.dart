import 'package:elka/provider/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _sliderState();
}

class _sliderState extends State<BannerSlider>
    with AutomaticKeepAliveClientMixin {
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<NavigationProvider>(
      builder: (context, data, c) {
        return Container(
          child: FlutterCarousel(
            options: FlutterCarouselOptions(
              disableCenter: true,

              indicatorMargin: 0,
              aspectRatio: 6 / 2.3,
              viewportFraction: 0.925,
              pageSnapping: true,
              autoPlay: false,
              autoPlayInterval: const Duration(seconds: 5),

              enableInfiniteScroll: false,
              slideIndicator: CircularSlideIndicator(
                slideIndicatorOptions: SlideIndicatorOptions(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(0),
                  indicatorRadius: 4.5,
                  indicatorBackgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.3),
                  currentIndicatorColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            items: List.generate(
              data.sliderItems.length,
              (index) => Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(left: 3, right: 3, bottom: 20),
                child: InkWell(
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 150));

                    _launchInBrowser(Uri.parse(data.sliderItems[index].link));
                  },
                  child: CachedNetworkImage(
                    imageUrl: data.sliderItems[index].imgUrl,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // @override
  // TODO: implement wantKeepAlive
  @override
  bool get wantKeepAlive => true;
}
