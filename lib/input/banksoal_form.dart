import 'package:elka/model/bank_soal.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

class BankSoalManagementScreen extends StatefulWidget {
  final String kelasSubjectId;
  final BankSoal? existingBankSoal; // Null for add, non-null for edit

  const BankSoalManagementScreen({
    required this.kelasSubjectId,
    this.existingBankSoal,
    Key? key,
  }) : super(key: key);

  @override
  _BankSoalManagementScreenState createState() =>
      _BankSoalManagementScreenState();
}

class _BankSoalManagementScreenState extends State<BankSoalManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _quizLinkController;
  late TextEditingController _kelasIdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingBankSoal?.title ?? '',
    );
    _quizLinkController = TextEditingController(
      text: widget.existingBankSoal?.quizLink ?? '',
    );
    _kelasIdController = TextEditingController(
      text: widget.existingBankSoal?.kelasId ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quizLinkController.dispose();
    _kelasIdController.dispose();
    super.dispose();
  }

  Future<void> _saveBankSoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bankSoalRef = FirebaseDatabase.instance.ref(
        'bank_soal/${widget.kelasSubjectId}',
      );

      final newBankSoal = BankSoal(
        kelasSubjectId: widget.kelasSubjectId,
        kelasId: context.read<NavigationProvider>().currentUser!.kelasId,
        quizLink: _quizLinkController.text.trim(),
        title: _titleController.text.trim(),
      );

      if (widget.existingBankSoal == null) {
        // Add new
        await bankSoalRef.push().set(newBankSoal.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank Soal added successfully!')),
        );
      } else {
        // Update existing
        // Note: You'll need the original ID to update
        // This assumes the existingBankSoal has an 'id' field from Firebase
        final id =
            widget
                .existingBankSoal!
                .id; // You might need to add this to your model
        await bankSoalRef.child(id).update(newBankSoal.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank Soal updated successfully!')),
        );
      }

      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving Bank Soal: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBankSoal == null ? 'Add Bank Soal' : 'Edit Bank Soal',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quizLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Quiz Link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quiz link';
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _saveBankSoal,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Bank Soal'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
