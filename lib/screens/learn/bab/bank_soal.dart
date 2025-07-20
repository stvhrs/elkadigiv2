import 'package:elka/input/bank_soal_from_pdf.dart';
import 'package:elka/input/banksoal_form.dart';
import 'package:elka/model/bank_soal.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/quiz_button.dart';
import 'package:elka/screens/learn/subab/subab_pdf_detail.dart';
import 'package:elka/screens/learn/subab/timeline.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankSoalScreen extends StatefulWidget {
  const BankSoalScreen({super.key});

  @override
  State<BankSoalScreen> createState() => _BankSoalScreenState();
}

class _BankSoalScreenState extends State<BankSoalScreen> {
  final FirebaseService _repository = FirebaseService();
  List<BankSoalpdf> _bankSoalFuture = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData({bool forceRefresh = false}) async {
    var prov =
        context.read<NavigationProvider>().currentUser!.kelasId +
        "_" +
        context.read<NavigationProvider>().selectedSubject!.id;
    _isRefreshing = forceRefresh;
    _bankSoalFuture = await _repository.fetchBankSoalPdf(
      kelasSubjectId: prov,
      forceRefresh: forceRefresh,
    );
    setState(() {});
  }

  Future<void> _refreshData() async {
    _loadData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    var kelasSubjectid =
        context.read<NavigationProvider>().currentUser!.kelasId +
        "_" +
        context.read<NavigationProvider>().selectedSubject!.id;
    var prov = context.read<NavigationProvider>();
    return Scaffold(
      floatingActionButton:
          FirebaseAuth.instance.currentUser!.uid !=
                  "0AdM3JnI6dUtdlti59uk2wfaHk83"
              ? SizedBox()
              : FloatingActionButton(
                backgroundColor: Colors.green,
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              BankSoalFormPDF(kelasSubjectId: kelasSubjectid),
                    ),
                  );
                },
              ),
      appBar: AppBar(
        backgroundColor: prov.color,
        title: const Text('Bank Soal IPA Kelas 7'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          children:
              _bankSoalFuture
                  .mapIndexed(
                    (e, i) =>
                        (prov.currentUser!.userType == UserType.SISWA &&
                                i.title.toLowerCase().contains("pembahasan"))
                            ? SizedBox()
                            : CustomTimelineTile(
                              isFirstItem: e == 0,
                              link: i.pdfUrl,
                              content: ShadowedContainer(
                                shadowColor: prov.color,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SubabPdfDetail(
                                              path: EmodulModel(
                                                id: "id",
                                                imgUrl: "",
                                                pdfUrl: i.pdfUrl,
                                                namaBuku: i.title,
                                                kelasId: "",
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            width: 30,
                                            i.title.toLowerCase().contains(
                                                  "pembahasan",
                                                )
                                                ? "asset/formatif.png"
                                                : "asset/sumatif.png",
                                          ),
                                          SizedBox(width: 15),
                                          Text(i.title),
                                        ],
                                      ),
                                      FirebaseAuth.instance.currentUser!.uid !=
                                              "0AdM3JnI6dUtdlti59uk2wfaHk83"
                                          ? SizedBox()
                                          : IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.green,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          BankSoalFormPDF(
                                                            kelasSubjectId:
                                                                kelasSubjectid,
                                                            bankSoalData:
                                                                i.toMap(),
                                                          ),
                                                ),
                                              );
                                            },
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
