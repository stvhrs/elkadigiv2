import 'package:elka/helper.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/emodul/emodul_detail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_touch_ripple/widgets/touch_ripple.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmodulItem extends StatelessWidget {
  EmodulModel e;
  EmodulItem(this.e, {super.key});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  RegExp romanNumerals = RegExp(r"\b[IVXLCDM]+\b");
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Helper.localColor(e.namaBuku),

        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        // rippleColor: Helper.localColor(e.namaBuku).withOpacity(0.2),
        onTap: () async {
          await Future.delayed(Duration(milliseconds: 180));
          context.read<NavigationProvider>().setColor(
            Helper.localColor(e.namaBuku),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EmodulDetail(path: e)),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: e.imgUrl,
                  fit: BoxFit.cover,

                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(color: Colors.grey.shade300),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 6),

            Expanded(
              child: Center(
                child: Text(
                  e.namaBuku,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,

                    fontSize: 9,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
