import 'package:elka/helper.dart';
import 'package:elka/input/babform.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/bab/bab_appbar.dart';
import 'package:elka/screens/learn/bab/bank_soal.dart';
import 'package:elka/screens/learn/material/course_screen.dart';
import 'package:elka/screens/learn/subab/subab_page.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _HalamanMapelState();
}

class _HalamanMapelState extends State<SubjectPage> {
  @override
  initState() {
    init(false);
    super.initState();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  init(bool refresh) async {
    var data = await FirebaseService().getBabsByKelasAndSubject(
      context.read<NavigationProvider>().currentUser!.kelasId,
      context.read<NavigationProvider>().selectedSubject!.id,
      forceRefresh: refresh,
    );
    context.read<NavigationProvider>().setBabs(data);
  }

  @override
  Widget build(BuildContext context) {
    var prov = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: BabAppbar(),
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
                  ).push(MaterialPageRoute(builder: (context) => BabForm()));
                },
              ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          await init(true);
        },
        child: Container(
          padding: EdgeInsets.only(top: 10, left: 15, right: 15),
          child: prov.babs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Nantikan konten dari Elkadigi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ShadowedContainer(
                            shadowColor: prov.color,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BankSoalScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "asset/sumatif.png",
                                      width: MediaQuery.of(context).size.width * 0.09,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bank Soal ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color.fromRGBO(53, 53, 53, 1),
                                            ),
                                          ),
                                          Text(
                                            "ASTS & ASAS ",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
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
                        SizedBox(width: 16),
                        Expanded(
                          child: ShadowedContainer(
                            shadowColor: prov.color,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CourseScreen(prov.color),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "asset/formatif.png",
                                      width: MediaQuery.of(context).size.width * 0.09,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Materi Sekolah ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color.fromRGBO(53, 53, 53, 1),
                                            ),
                                          ),
                                          Text(
                                            "Dikirim Guru",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
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
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, top: 18),
                      child: Text(
                        "Daftar bab",
                        style: TextStyle(
                          color: Color.fromRGBO(53, 53, 53, 1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Column(
                      children: List.generate(
                        prov.babs.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () {
                              prov.setSelectedBab(prov.babs[index]);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SubabPage(index: index + 1),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.18,
                              child: ShadowedContainer(
                                shadowColor: prov.color,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                        left: 12,
                                        right: 16,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: prov.babs[index].imageUrl,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                prov.babs[index].title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color.fromRGBO(
                                                    53,
                                                    53,
                                                    53,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Bab ${index + 1}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: prov.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FirebaseAuth.instance.currentUser!.uid !=
                                            "0AdM3JnI6dUtdlti59uk2wfaHk83"
                                        ? SizedBox()
                                        : IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => BabForm(
                                                      babId: prov.babs[index].id,
                                                      order: index + 1,
                                                      babData:
                                                          prov.babs[index].toMap(),
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}