import 'dart:io';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SubabForm extends StatefulWidget {
  final Map<dynamic, dynamic>? subabData;
  final String? subabId;
  final int? order;

  const SubabForm({super.key, this.order, this.subabData, this.subabId});

  @override
  State<SubabForm> createState() => _SubabFormState();
}

class _SubabFormState extends State<SubabForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleExcercieController = TextEditingController();

  final _youtubeMaterialController = TextEditingController();
  final _youtubeExerciseController = TextEditingController();

  PlatformFile? _pdfFile;
  bool isUploading = false;
  late DatabaseReference _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref('subabs');

    if (widget.subabData != null) {
      final data = widget.subabData!;
      _titleController.text = data['title'] ?? '';
      _titleExcercieController.text = data["exercise_title"] ?? "";

      _youtubeMaterialController.text = data['youtube_material'] ?? '';
      _youtubeExerciseController.text = data['youtube_exercise'] ?? '';
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pdfFile = result.files.first);
    }
  }

  Future<String> uploadPdfToStorage(PlatformFile file, String path) async {
    final ext = file.extension ?? 'pdf';
    final ref = FirebaseStorage.instance.ref().child('$path.$ext');
    UploadTask uploadTask =
        kIsWeb ? ref.putData(file.bytes!) : ref.putFile(File(file.path!));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveSubab() async {
    var prov = context.read<NavigationProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);
    final Uuid _uuid = const Uuid();

    String subabId = widget.subabId ?? _uuid.v4();
    String? pdfUrl = widget.subabData?['pdfUrl'];
    if (widget.subabId != null) {
      subabId = widget.subabId!;
    }
    ;
    try {
      if (_pdfFile != null) {
        pdfUrl = await uploadPdfToStorage(_pdfFile!, 'subab_pdfs/$subabId');
      }
      int orderIndex = prov.subabs.length;

      // Dummy kelasId, subjectId, babId (harus diganti sesuai implementasi navigasi/konteks)
      final subabData = {
        'id': subabId,
        'kelas_id': prov.currentUser.kelasId,
        'subject_id': prov.selectedSubject!.id,
        'bab_id': prov.selectedBab!.id,
        'title': _titleController.text.trim(),
        "exercise_title": _titleExcercieController.text.trim(),
        'pdfUrl': pdfUrl,
        'youtube_material': _youtubeMaterialController.text.trim(),
        'order_index': widget.order ?? orderIndex + 1, // Tambahkan index urutan

        'youtube_exercise': _youtubeExerciseController.text.trim(),
      };

      await _ref.child(subabId).set(subabData);
      var data = await FirebaseService().getSubabsByBab(
        context.read<NavigationProvider>().selectedBab!.id,
      );
      context.read<NavigationProvider>().setSubabs(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subab berhasil disimpan')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text(widget.subabData == null ? 'Tambah Subab' : 'Edit Subab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama Subab'),
              ),

              TextFormField(
                controller: _youtubeMaterialController,
                decoration: const InputDecoration(
                  labelText: 'Link YouTube Materi',
                ),
              ),
              TextFormField(
                controller: _titleExcercieController,
                decoration: const InputDecoration(
                  labelText: 'Judul Youtube Latihan',
                ),
              ),
              TextFormField(
                controller: _youtubeExerciseController,
                decoration: const InputDecoration(
                  labelText: 'Link YouTube Latihan',
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickPdf,
                child: Text(
                  _pdfFile == null
                      ? (widget.subabData == null ? 'Pilih PDF' : 'Ubah PDF')
                      : _pdfFile!.name,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isUploading ? null : saveSubab,
                child:
                    isUploading
                        ? const CircularProgressIndicator()
                        : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
