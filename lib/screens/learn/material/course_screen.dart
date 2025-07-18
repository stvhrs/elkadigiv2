import 'dart:developer';

import 'package:elka/model/material.dart';
import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/material/upload_course.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mime/mime.dart';

class CourseScreen extends StatefulWidget {
  final Color color;
  CourseScreen(this.color);
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  // Menghapus streams dan isLoading karena FutureBuilder akan menangani itu
  @override
  void initState() {
    var ctx = context.read<NavigationProvider>();

    context.read<NavigationProvider>().fetchCourses(
      ctx!.currentUser!.npsn,
      ctx!.currentUser!.kelasId,
      ctx!.selectedSubject!.id,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var prov = context.read<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: prov.color,
        title: Text("Materi dari Sekolah"),
      ),
      floatingActionButton:
          context.read<NavigationProvider>().currentUser!.userType ==
                  UserType.SISWA
              ? SizedBox()
              : InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UploadMateri()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Input Materi +",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<NavigationProvider>(
              builder: (context, courseProvider, child) {
                if (courseProvider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(64.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (courseProvider.errorMessage.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Error: ${courseProvider.errorMessage}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                } else if (courseProvider.courses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Belum ada Materi dari Guru kamu",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children:
                        courseProvider.courses.map((stream) {
                          return ShadowedContainer(
                            shadowColor: prov.color,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            child: InkWell(
                              onTap:
                                  () => _showSupportingMaterials(
                                    context,
                                    stream['title'],
                                    stream["content"],
                                    "",
                                  ),
                              child: Container(
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stream['title'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: widget.color,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Dikirm oleh: ${stream['sender']}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    context
                                                .read<NavigationProvider>()
                                                .currentUser!
                                                .userType ==
                                            UserType.SISWA
                                        ? SizedBox()
                                        : IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => UploadMateri(
                                                      materialToEdit:
                                                          MaterialCourse.fromMap(
                                                            stream,
                                                          ),
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.green,
                                          ),
                                        ),
                                    context
                                                .read<NavigationProvider>()
                                                .currentUser!
                                                .userType ==
                                            UserType.SISWA
                                        ? SizedBox()
                                        : IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => UploadMateri(
                                                      materialToEdit:
                                                          MaterialCourse.fromMap(
                                                            stream,
                                                          ),
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showSupportingMaterials(
  BuildContext context,

  String title,
  dynamic materi,
  String submbab,
) {
  // log(jsonDecode(materi).runtimeType.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Judul bab',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              HtmlWidget(title),

              SizedBox(height: 16),
              Text(
                'Materi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              QuillEditor.basic(
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
                          if (imageUrl.startsWith('data:image/')) {
                            try {
                              final base64String = imageUrl.split(',').last;
                              final bytes = base64Decode(base64String);
                              return MemoryImage(bytes);
                            } catch (e) {
                              debugPrint("Error decoding base64 image: $e");
                              return null;
                            }
                          }

                          if (imageUrl.startsWith('http')) {
                            return NetworkImage(imageUrl);
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                controller: QuillController(
                  document: Document.fromJson(materi),
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
