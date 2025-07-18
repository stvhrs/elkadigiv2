import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/bab/bab_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_touch_ripple/widgets/touch_ripple.dart';
import 'package:provider/provider.dart';

class LearnButton extends StatefulWidget {
  final Subject subject;
  const LearnButton(this.subject, {super.key});

  @override
  State<LearnButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<LearnButton> {
  String dropdownValue = list.first;

  Color lightenColor(Color color, [double amount = 0.15]) {
    // Use Color.lerp to mix the color with white
    return Color.lerp(color, Colors.white, amount)!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // rippleBorderRadius: BorderRadius.circular(8),
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 180));

        context.read<NavigationProvider>().setBabs([]);
        context.read<NavigationProvider>().setSelectedSubject(widget.subject);
        context.read<NavigationProvider>().setColor(
          Helper.localColor(widget.subject.name),
        );

        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => SubjectPage()));
      },

      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Helper.localColor(widget.subject.name),

          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.subject.imageUrl,
                  fit: BoxFit.cover,
                  httpHeaders: {
                    'Access-Control-Allow-Origin': '*',
                  }, // Force CORS

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
                  widget.subject.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,

                    fontSize: 11,
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
