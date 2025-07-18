import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io show Directory, File;

import 'package:elka/main.dart';
import 'package:elka/model/material.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

class ButtonLoading extends StatefulWidget {
  final Function? callback; // Notice the variable type
  final String title;
  final bool disabled;
  const ButtonLoading(this.callback, this.title, this.disabled, {super.key});
  @override
  State<ButtonLoading> createState() => _ButtonLoadingState();
}

class _ButtonLoadingState extends State<ButtonLoading> {
  var _isLoading = false;
  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);

    try {
      await widget.callback!(); // Call the callback function
    } catch (e) {
      // Handle any errors that occur during the callback
      // You can log the error or show an error message
      print('Error occurred: $e');
    } finally {
      // This block will run whether the callback succeeds or fails
      setState(() => _isLoading = false);
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.disabled || _isLoading) ? null : _onSubmit,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromHeight(50),
        padding: const EdgeInsets.all(16.0),
        backgroundColor: context.read<NavigationProvider>().color,
      ),
      child:
          _isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              )
              : Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
    );
  }
}

Future<List<Map<dynamic, dynamic>>> convertFileImagesToBase64(
  List<Map<dynamic, dynamic>> deltaOps,
) async {
  final updatedDelta = <Map<dynamic, dynamic>>[];

  for (final op in deltaOps) {
    if (op.containsKey('insert') &&
        op['insert'] is Map &&
        op['insert'].containsKey('image')) {
      final imagePath = op['insert']['image'];

      if (imagePath is String && imagePath.startsWith('/')) {
        // Local file path
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final mimeType = lookupMimeType(imagePath) ?? 'image/png';
          final base64Str = base64Encode(bytes);
          final base64Uri = 'data:$mimeType;base64,$base64Str';

          updatedDelta.add({
            'insert': {'image': base64Uri},
          });
        } else {
          // If file doesn't exist, skip or keep original
          updatedDelta.add(op);
        }
      } else {
        // Network or already base64
        updatedDelta.add(op);
      }
    } else {
      // Non-image insert (e.g., text)
      updatedDelta.add(op);
    }
  }

  return updatedDelta;
}

class UploadMateri extends StatefulWidget {
  final MaterialCourse? materialToEdit; // Parameter untuk edit
  const UploadMateri({super.key, this.materialToEdit});

  @override
  State<UploadMateri> createState() => _UploadMateriState();
}

class _UploadMateriState extends State<UploadMateri> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  bool _isEditing = false;
  String? _documentId; // Untuk menyimpan ID dokumen yang diedit

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();

    // Jika ada materialToEdit, berarti mode edit
    if (widget.materialToEdit != null) {
      _isEditing = true;
      _documentId = widget.materialToEdit!.id;
      titleController.text = widget.materialToEdit!.title;

      // Load konten materi ke Quill Editor
      try {
        final content = widget.materialToEdit!.content;
        if (content != null && content.isNotEmpty) {
          final doc = Document.fromJson(content);
          _controller.document = doc;
        }
      } catch (e) {
        debugPrint('Error loading document: $e');
      }
    } else {
      _controller.document = Document();
    }

    _controller.addListener(() {
      String deltaJson = jsonEncode(_controller.document.toDelta().toJson());
      log(deltaJson);
    });
  }

  Future convertImageToBase64DataUri() async {
    final newDeltaJson = await convertFileImagesToBase64(
      _controller.document.toDelta().toJson(),
    );
    return newDeltaJson;
  }

  // Fungsi untuk mengupdate materi yang sudah ada
  Future<void> _updateMaterial() async {
    var ctx = context.read<NavigationProvider>();
    var nspnKelasMapelId =
        "${ctx.currentUser!.npsn}_${ctx.currentUser!.kelasId}_${ctx.selectedSubject!.id}";

    final updatedMaterial = MaterialCourse.fromMap({
      'id': _documentId,
      'title': titleController.text,
      "nspnKelasMapelId": nspnKelasMapelId,
      "sender": ctx.currentUser!.name,
      'content': await convertImageToBase64DataUri(),
      "npsn": ctx.currentUser!.npsn,
      'published_at': DateFormat('dd-MM-yyyy').format(DateTime.now()),
      'updated_at':
          DateTime.now().toIso8601String(), // Tambahkan timestamp update
    });

    await ctx.editCourse(updatedMaterial);
  }

  // Fungsi untuk membuat materi baru
  Future<void> _createMaterial() async {
    var ctx = context.read<NavigationProvider>();
    var nspnKelasMapelId =
        "${ctx.currentUser!.npsn}_${ctx.currentUser!.kelasId}_${ctx.selectedSubject!.id}";
    final newMaterial = MaterialCourse.fromMap({
      'title': titleController.text,
      "nspnKelasMapelId": nspnKelasMapelId,
      "sender": ctx.currentUser!.name,
      'content': await convertImageToBase64DataUri(),
      "npsn": ctx.currentUser!.npsn,
      'published_at': DateFormat('dd-MM-yyyy').format(DateTime.now()),
      'created_at': DateTime.now().toIso8601String(),
    });

    await ctx.addCourse(newMaterial.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ButtonLoading(
                () async {
                  if (_controller.document!.length == 0 ||
                      titleController.text.isEmpty) {
                    return;
                  }
                  if (widget.materialToEdit != null) {
                    await _updateMaterial();
                  } else {
                    await _createMaterial();
                  }

                  Navigator.of(context).pop();
                },
                "Upload Materi",
                false,
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: context.read<NavigationProvider>().color,
        title: Text('Upload Materi'),
        actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                TextFormField(
                  controller: titleController,

                  validator:
                      (value) =>
                          value!.isEmpty ? 'Title cannot be empty' : null,
                ),

                // Supporting Materials Input Field
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.read<NavigationProvider>().color,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      QuillSimpleToolbar(
                        controller: _controller,
                        config: QuillSimpleToolbarConfig(
                          showAlignmentButtons: false,
                          showBackgroundColorButton: false,
                          showClearFormat: false,
                          showCodeBlock: false,
                          showDirection: false,
                          showDividers: false,
                          showFontFamily: false,
                          showHeaderStyle: false,
                          showIndent: false,
                          showLink: false,
                          showListBullets: false,
                          showListCheck: false,
                          showFontSize: true,
                          showListNumbers: false,
                          showQuote: false,
                          showSearchButton: false,
                          showStrikeThrough: false,
                          showUndo: false,
                          showRedo: false,
                          showClipboardCopy: false,
                          showClipboardCut: false,
                          showClipboardPaste: false,
                          showInlineCode: false,
                          embedButtons:
                              FlutterQuillEmbeds.toolbarButtons()
                                  .getRange(0, 1)
                                  .toList(),
                          customButtons: [],
                          buttonOptions: QuillSimpleToolbarButtonOptions(
                            base: QuillToolbarBaseButtonOptions(
                              afterButtonPressed: () {
                                final isDesktop = {
                                  TargetPlatform.linux,
                                  TargetPlatform.windows,
                                  TargetPlatform.macOS,
                                }.contains(defaultTargetPlatform);
                                if (isDesktop) {
                                  _editorFocusNode.requestFocus();
                                }
                              },
                            ),
                            linkStyle: QuillToolbarLinkStyleButtonOptions(
                              validateLink: (link) {
                                // Treats all links as valid. When launching the URL,
                                // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
                                // however this happens only within the editor.
                                return true;
                              },
                            ),
                          ),
                        ),
                      ),
                      Divider(color: context.read<NavigationProvider>().color),
                      Container(
                        constraints: BoxConstraints(minHeight: 200),

                        child: QuillEditor.basic(
                          focusNode: _editorFocusNode,
                          scrollController: _editorScrollController,
                          controller: _controller,
                          config: QuillEditorConfig(
                            placeholder: 'Mulai Tulis Materi...',
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
                                        final base64String =
                                            imageUrl.split(',').last;
                                        final bytes = base64Decode(
                                          base64String,
                                        );
                                        return MemoryImage(bytes);
                                      } catch (e) {
                                        debugPrint(
                                          "Error decoding base64 image: $e",
                                        );
                                        return null;
                                      }
                                    }

                                    if (imageUrl.startsWith('http')) {
                                      return NetworkImage(imageUrl);
                                    }
                                    return null;
                                  },
                                ),
                                videoEmbedConfig: QuillEditorVideoEmbedConfig(
                                  customVideoBuilder: (videoUrl, readOnly) {
                                    // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  // ... (method lainnya tetap sama)
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(String value) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
