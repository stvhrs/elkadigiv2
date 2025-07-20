import 'package:elka/helper.dart';
import 'package:elka/input/bookform.dart';
import 'package:elka/model/book_model.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/screens/emodul/emodul_detail.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_touch_ripple/widgets/touch_ripple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookItem extends StatelessWidget {
  Book e;
  BookItem(this.e, {super.key});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  RegExp romanNumerals = RegExp(r"\b[IVXLCDM]+\b");
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // rippleBorderRadius: BorderRadius.circular(8),
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 180));
        _launchInBrowser(Uri.parse(e.pdfUrl));
      },
      child: Stack(
        children: [
          ShadowedContainer(
            shadowColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(0),
          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child:  CachedNetworkImage(
                        imageUrl: e.imgUrl,
                        fit: BoxFit.fitWidth,
          
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "asset/place.png",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  
                
          
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      e.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(53, 53, 53, 1),
          
                        fontSize: 9,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),FirebaseAuth.instance.currentUser!.uid !=
                    "0AdM3JnI6dUtdlti59uk2wfaHk83"
                ? SizedBox()
                : IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                BookForm(bookData: e.toMap(), bookId: e.id),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.black),
                ),
        ],
      ),
    );
  }
}
