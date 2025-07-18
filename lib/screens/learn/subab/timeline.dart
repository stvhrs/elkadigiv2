import 'dart:developer';

import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class CustomTimelineTile extends StatefulWidget {
  final bool isFirstItem;
  final String link;
  final Widget content;
  final bool isLast;

  const CustomTimelineTile({
    super.key,
    this.isFirstItem = false,
    this.isLast = false,
    required this.link,
    required this.content,
  });

  @override
  State<CustomTimelineTile> createState() => _CustomTimelineTileState();
}

class _CustomTimelineTileState extends State<CustomTimelineTile> {
  dynamic? _cachedScore;
  bool showCheckmark = false;

  Future<void> _loadCachedScore() async {
    // setState(() => _loading = true);
    _cachedScore = box.get(widget.link);
    log("$_cachedScore Socre");
    if (_cachedScore != null) {
      showCheckmark = true;
    }
    // Update provider if needed
    // final provider = Provider.of<NavigationProvider>(context, listen: false);
    // if (provider.scoreDiagnostic != _cachedScore) {
    //   provider.setScoreDiagnostic(_cachedScore.toDouble());
    // }

    // setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    _loadCachedScore();
    var prov = context.watch<NavigationProvider>();

    return TimelineTile(
      node: TimelineNode.simple(
        nodePosition: 0,
        lineThickness: 3.5,
        drawEndConnector: !widget.isLast,
        drawStartConnector: !widget.isFirstItem,
        overlap: true,
        color: Helper.lightenColor(prov.color, 0.8),
        indicatorChild: Stack(
          alignment: Alignment.center,
          children: [
            DotIndicator(size: 18, color: Helper.lightenColor(prov.color, 0.8)),
            showCheckmark
                ? Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prov.color,
                  ),
                  child: const Icon(
                    size: 10,
                    Icons.check_rounded,
                    color: Colors.white,
                  ),
                )
                : const SizedBox(),
          ],
        ),
      ),
      contents: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 16, bottom: 16),
          child: widget.content,
        ),
      ),
    );
  }
}
