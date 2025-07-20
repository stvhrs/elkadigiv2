import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class BankSoalFormPDF extends StatefulWidget {
  final Map<dynamic, dynamic>? bankSoalData;
  final String? bankSoalId;
  final String kelasSubjectId; // New property

  const BankSoalFormPDF({
    super.key, 
    this.bankSoalData, 
    this.bankSoalId,
    required this.kelasSubjectId, // Required parameter
  });

  @override
  State<BankSoalFormPDF> createState() => _BankSoalFormPDFState();
}

class _BankSoalFormPDFState extends State<BankSoalFormPDF> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  PlatformFile? _pdfFile;
  bool isUploading = false;
  late DatabaseReference _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref('bank_soal_pdf');

    if (widget.bankSoalData != null) {
      final data = widget.bankSoalData!;
      _titleController.text = data['title'] ?? '';
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
    UploadTask uploadTask;
    
    if (kIsWeb) {
      uploadTask = ref.putData(file.bytes!);
    } else {
      uploadTask = ref.putFile(File(file.path!));
    }
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveBankSoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);
    final Uuid _uuid = const Uuid();

    String bankSoalId = widget.bankSoalId ?? _uuid.v4();
    String? pdfUrl = widget.bankSoalData?['pdfUrl'];

    try {
      if (_pdfFile != null) {
        pdfUrl = await uploadPdfToStorage(_pdfFile!, 'bank_soal_pdf/$bankSoalId');
      }

      final bankSoalData = {
        'id': bankSoalId,
        'title': _titleController.text.trim(),
        'pdfUrl': pdfUrl,
        'kelasSubjectId': widget.kelasSubjectId, // Added kelasSubjectId
      };

      await _ref.child(bankSoalId).set(bankSoalData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank soal berhasil disimpan'))
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'))
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bankSoalData == null ? 'Tambah Bank Soal' : 'Edit Bank Soal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Bank Soal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickPdf,
                child: Text(
                  _pdfFile == null
                      ? (widget.bankSoalData == null ? 'Pilih PDF' : 'Ubah PDF')
                      : _pdfFile!.name,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isUploading ? null : saveBankSoal,
                child: isUploading
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