import 'dart:io';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BabForm extends StatefulWidget {
  final Map<dynamic, dynamic>? babData;
  final String? babId;
  final int? order;

  const BabForm({super.key, this.babData, this.babId, this.order});

  @override
  State<BabForm> createState() => _BabFormState();
}

class _BabFormState extends State<BabForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _youtubeIntroController = TextEditingController();
  final _youtubeIntroTitleController = TextEditingController();
  final _diagnosticQuizController = TextEditingController();
  final _summativeQuizController = TextEditingController();

  PlatformFile? _pdfFile;
  PlatformFile? _imageFile;
  bool isUploading = false;
  late DatabaseReference _ref;
  final Uuid _uuid = const Uuid();

  // Helper function to convert empty string to "Kosong"
  String _emptyToKosong(String value) {
    return value.trim().isEmpty ? "Kosong" : value.trim();
  }

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref('babs');

    if (widget.babData != null) {
      final data = widget.babData!;
      _titleController.text = data['title'] ?? '';
      _youtubeIntroController.text = data['youtube_introduction'] ?? '';
      _youtubeIntroTitleController.text =
          data['youtube_introduction_title'] ?? '';
      _diagnosticQuizController.text = data['diagnosticQuiz'] ?? '';
      _summativeQuizController.text = data['summativeQuiz'] ?? '';
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfFile = result.files.first;
      });
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageFile = result.files.first;
      });
    }
  }

  Future<String> uploadFileToStorage(PlatformFile file, String path) async {
    final ext = file.extension ?? '';
    final ref = FirebaseStorage.instance.ref().child('$path.$ext');

    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(file.bytes!);
    } else {
      uploadTask = ref.putFile(File(file.path!));
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveBab() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);
    var prov = context.read<NavigationProvider>();
    final String babId = widget.babId ?? _uuid.v4();

    try {
      String? pdfUrl = widget.babData?['summaryPdfUrl'] ?? "Kosong";
      String? imageUrl = widget.babData?['imageUrl'] ?? "Kosong";

      if (_pdfFile != null) {
        pdfUrl = await uploadFileToStorage(_pdfFile!, 'bab_summary/$babId');
      }

      if (_imageFile != null) {
        imageUrl = await uploadFileToStorage(_imageFile!, 'bab_images/$babId');
      }

      final kelasId = prov.currentUser.kelasId;
      final subjectId = prov.selectedSubject!.id;

      // Get youtube_introduction value
      final ytLink = _emptyToKosong(_youtubeIntroController.text);
      int orderIndex = prov.babs.length;

      final babData = {
        'id': babId,
        'kelas_id': kelasId,
        'subject_id': subjectId,
        'kelasSubjectId': '$kelasId\_$subjectId',
        'title': _emptyToKosong(_titleController.text),
        'youtube_introduction': ytLink,
        'youtube_introduction_title': _emptyToKosong(
          _youtubeIntroTitleController.text,
        ),
        'diagnosticQuiz': _emptyToKosong(_diagnosticQuizController.text),
        'summativeQuiz': _emptyToKosong(_summativeQuizController.text),
        'summaryPdfUrl': pdfUrl,
        'imageUrl': imageUrl,
        'order_index': widget.order ?? orderIndex + 1, // Tambahkan index urutan
        'ytLink': ytLink, // Copy from youtube_introduction
      };

      await _ref.child(babId).set(babData);

      var data = await FirebaseService().getBabsByKelasAndSubject(
        kelasId,
        subjectId,
      );
      prov.setBabs(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bab saved successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text(widget.babData == null ? 'Add Bab' : 'Edit Bab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _youtubeIntroController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Introduction Link',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _youtubeIntroTitleController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Introduction Title',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosticQuizController,
                decoration: const InputDecoration(
                  labelText: 'Diagnostic Quiz Link',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summativeQuizController,
                decoration: const InputDecoration(
                  labelText: 'Summative Quiz Link',
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                ),
                onPressed: pickPdf,
                child: Text(
                  _pdfFile == null
                      ? (widget.babData == null
                          ? 'Select Summary PDF'
                          : 'Change Summary PDF')
                      : _pdfFile!.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                ),
                onPressed: pickImage,
                child: Text(
                  _imageFile == null
                      ? (widget.babData == null
                          ? 'Select Thumbnail Image'
                          : 'Change Thumbnail Image')
                      : _imageFile!.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: isUploading ? null : saveBab,
                child:
                    isUploading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
