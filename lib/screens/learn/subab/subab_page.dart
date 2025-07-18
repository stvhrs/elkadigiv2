import 'dart:math';
import 'package:elka/helper.dart';
import 'package:elka/input/suababform.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/model/quiz_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/emodul/emodul_detail.dart';
import 'package:elka/screens/learn/bab/bab_appbar.dart';
import 'package:elka/screens/learn/subab/quiz_button.dart';
import 'package:elka/screens/learn/subab/subab_pdf.dart';
import 'package:elka/screens/learn/subab/suabb_tabar.dart';
import 'package:elka/screens/learn/subab/subab_appbar.dart';
import 'package:elka/screens/learn/subab/timeline.dart';
import 'package:elka/screens/learn/subab/video_item.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SubabPage extends StatefulWidget {
  const SubabPage({super.key, required this.index});
  final int index;

  @override
  State<SubabPage> createState() => _HalamanMapelState();
}

class _HalamanMapelState extends State<SubabPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    var data = await FirebaseService().getSubabsByBab(
      context.read<NavigationProvider>().selectedBab!.id,
    );
    context.read<NavigationProvider>().setSubabs(data);
  }

  List<int> listpage = [3, 4, 7, 9];

  @override
  Widget build(BuildContext context) {
    var prov = context.watch<NavigationProvider>();
    return Scaffold(
      floatingActionButton:
          FirebaseAuth.instance.currentUser!.uid !=
                  "0AdM3JnI6dUtdlti59uk2wfaHk83"
              ? SizedBox()
              : FloatingActionButton(
                backgroundColor: Colors.green,
                child:
                    FirebaseAuth.instance.currentUser!.uid !=
                            "0AdM3JnI6dUtdlti59uk2wfaHk83"
                        ? SizedBox()
                        : Icon(Icons.add, color: Colors.white),

                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => SubabForm()));
                },
              ),
      backgroundColor: Helper.lightenColor(prov.color, 0.99),
      appBar: SubabAppabr(),
      body: Container(margin: EdgeInsets.only(top: 16), child: SuabbTabar()),
    );
  }
}
