import 'package:cached_network_image/cached_network_image.dart';
import 'package:elka/input/suababform.dart';
import 'package:elka/main.dart';
import 'package:elka/screens/emodul/emodul.dart';
import 'package:elka/screens/learn/subab/diagnostic_button.dart';
import 'package:elka/screens/learn/subab/subab_pdf_detail.dart';
import 'package:elka/screens/learn/subab/video_apresepsi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:elka/helper.dart';
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SuabbTabar extends StatefulWidget {
  const SuabbTabar({super.key});

  @override
  State<SuabbTabar> createState() => _SuabbTabarState();
}

class _SuabbTabarState extends State<SuabbTabar> {
  @override
  void initState() {
    super.initState();
    var prov = context.read<NavigationProvider>();

    var score = box.get(prov.selectedBab!.diagnosticQuiz, defaultValue: 0);
    prov.setScoreDiagnostic(score.toDouble(), false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prov = context.watch<NavigationProvider>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: Column(
                    children:
                        prov.subabs
                            .mapIndexed(
                              (index, e) => Container(
                                margin: EdgeInsets.only(top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    index == 0
                                        ? CustomTimelineTile(
                                          link: prov.selectedBab!.summaryPdfUrl,
                                          content: ShadowedContainer(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => SubabPdfDetail(
                                                          path: EmodulModel(
                                                            id: "id",
                                                            imgUrl: "",
                                                            pdfUrl:
                                                                prov
                                                                    .selectedBab!
                                                                    .summaryPdfUrl,
                                                            namaBuku:
                                                                "E-Modul "+prov.selectedSubject!.name,
                                                            kelasId: "kelasId",
                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          prov
                                                              .selectedSubject!
                                                              .imageUrl,
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.09,
                                                    ),
                                                  ),
                                                  Text(
                                                    "      E-Modul " +
                                                        prov
                                                            .selectedSubject!
                                                            .name
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            ),
                                          ),
                                        )
                                        : SizedBox(),
                                    // index == 0
                                    //     ? CustomTimelineTile(
                                    //       link:
                                    //           prov.selectedBab!.diagnosticQuiz,
                                    //       content: ShadowedContainer(
                                    //         shadowColor: prov.color!,
                                    //         child: DiagnosticButton(
                                    //           title: "Tes Diagnostik",
                                    //           link:
                                    //               prov
                                    //                   .selectedBab!
                                    //                   .diagnosticQuiz,
                                    //         ),
                                    //       ),
                                    //     )
                                    //     : SizedBox(),

                                    index == 0
                                        ? CustomTimelineTile(
                                          link:
                                              prov
                                                  .selectedBab!
                                                  .youtubeIntroduction,
                                          content: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => VideoPage(
                                                        prov
                                                            .selectedBab!
                                                            .youtubeIntroduction,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: VideoApresepsi(index),
                                          ),
                                        )
                                        : SizedBox(),

                                    CustomTimelineTile(
                                      link: prov.subabs[index].ytLinkMaterial,
                                      content: Stack(
                                        children: [
                                          VideoItem(index, true),
                                          // prov.scoreDiagnostic > 75
                                          //     ? SizedBox()
                                          //     : Positioned.fill(
                                          //       child: Container(
                                          //         decoration: BoxDecoration(
                                          //           color: Colors.black
                                          //               .withOpacity(0.6),
                                          //           borderRadius:
                                          //               BorderRadius.circular(
                                          //                 8,
                                          //               ),
                                          //         ),
                                          //         child: Center(
                                          //           child: Icon(
                                          //             Icons.lock,
                                          //             color: Colors.white,
                                          //             size: 16,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid !=
                                                  "0AdM3JnI6dUtdlti59uk2wfaHk83"
                                              ? SizedBox()
                                              : IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => SubabForm(
                                                            order: index + 1,
                                                            subabId:
                                                                prov
                                                                    .subabs[index]
                                                                    .id,
                                                            subabData:
                                                                prov.subabs[index]
                                                                    .toMap(),
                                                          ),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),

                                    prov.subabs[0].ytLinkExercise.isEmpty
                                        ? SizedBox()
                                        : CustomTimelineTile(
                                          link:
                                              prov.subabs[index].ytLinkExercise,
                                          content: Stack(
                                            children: [
                                              VideoItem(index, false),
                                              // prov.scoreDiagnostic > 75
                                              //     ? SizedBox()
                                              //     : Positioned.fill(
                                              //       child: Container(
                                              //         child: Center(
                                              //           child: Icon(
                                              //             Icons.lock,
                                              //             color: Colors.white,
                                              //             size: 16,
                                              //           ),
                                              //         ),
                                              //         decoration: BoxDecoration(
                                              //           color: Colors.black
                                              //               .withOpacity(0.6),
                                              //           borderRadius:
                                              //               BorderRadius.circular(
                                              //                 8,
                                              //               ),
                                              //         ),
                                              //       ),
                                              //     ),
                                            ],
                                          ),
                                        ),
                                    // index + 1 == prov.subabs.length
                                    //     ? Container(
                                    //       child: CustomTimelineTile(
                                    //         isLast: true,
                                    //         link:
                                    //             prov.selectedBab!.summativeQuiz,
                                    //         content: Stack(
                                    //           children: [
                                    //             ShadowedContainer(
                                    //               shadowColor: prov.color!,
                                    //               child: QuizButton(
                                    //                 title: "Assemen Sumatif",
                                    //                 color: prov.color,
                                    //                 link:
                                    //                     prov
                                    //                         .selectedBab!
                                    //                         .summativeQuiz,
                                    //               ),
                                    //             ),
                                    //             prov.scoreDiagnostic > 75
                                    //                 ? SizedBox()
                                    //                 : Positioned.fill(
                                    //                   child: Container(
                                    //                     child: Center(
                                    //                       child: Icon(
                                    //                         Icons.lock,
                                    //                         color: Colors.white,
                                    //                         size: 16,
                                    //                       ),
                                    //                     ),
                                    //                     decoration: BoxDecoration(
                                    //                       color: Colors.black
                                    //                           .withOpacity(0.6),
                                    //                       borderRadius:
                                    //                           BorderRadius.circular(
                                    //                             8,
                                    //                           ),
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     )
                                    //     : SizedBox(),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Container(
          //   margin: const EdgeInsets.all(16.0),
          //   child: Column(
          //     children:
          //         prov.subabs
          //             .mapIndexed(
          //               (index, element) => CustomTimelineTile(
          //                 isLast: index == prov.subabs.length - 1,
          //                 link: element.pdfUrl,
          //                 content: InkWell(
          //                   onTap: () {
          //                     Navigator.of(context).push(
          //                       MaterialPageRoute(
          //                         builder:
          //                             (context) => SubabPdfDetail(
          //                               path: EmodulModel(
          //                                 id: element.id,
          //                                 imgUrl: "",
          //                                 kelasId:
          //                                     prov.currentUser!.kelasId,
          //                                 namaBuku: element.title,
          //                                 pdfUrl: element.pdfUrl,
          //                               ),
          //                             ),
          //                       ),
          //                     );
          //                   },
          //                   child: ShadowedContainer(
          //                     child: SubabPdf(
          //                       subject: element.title,
          //                       color: prov.color,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             )
          //             .toList(),
          //   ),
          // ),
        ),
      ],
    );
  }
}
