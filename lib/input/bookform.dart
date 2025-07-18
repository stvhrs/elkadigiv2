import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BookForm extends StatefulWidget {
  final Map<dynamic, dynamic>? bookData; // Used for edit mode
  final String? bookId; // Used for edit mode

  const BookForm({super.key, this.bookData, this.bookId});

  @override
  _BookFormState createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imgUrlController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _kelasController =
      TextEditingController(); // Optional, for books with class
  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    // If bookData is passed (i.e., we are in edit mode), populate the controllers
    if (widget.bookData != null) {
      final data = widget.bookData!;
      _titleController.text = data['title'] ?? '';
      _imgUrlController.text = data['imgUrl'] ?? '';
      _pdfUrlController.text = data['pdfUrl'] ?? '';
      _kelasController.text = data['kelas'] ?? ''; // Optional
    }
  }

  // Save book data to Firebase
  Future<void> saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);

    // Prepare the book data
    final bookData = {
      'title': _titleController.text.trim(),
      'imgUrl': _imgUrlController.text.trim(),
      'pdfUrl': _pdfUrlController.text.trim(),
      'kelas':
          _kelasController.text.trim().isNotEmpty
              ? _kelasController.text.trim()
              : null, // Optional
    };

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('books');
      if (_kelasController.text.isEmpty) {
        ref = FirebaseDatabase.instance.ref('books_universal');
      }
      // Check if we are in edit mode (bookId is passed)
      if (widget.bookId != null) {
        // Update the existing book
        await ref.child(widget.bookId!).set(bookData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Book updated successfully')));
      } else {
        // Create a new book
        String bookId = DateTime.now().millisecondsSinceEpoch.toString();
        bookData["id"] = bookId;
        await ref.child(bookId).set(bookData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Book saved successfully')));
      }

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save book: $e')));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text(widget.bookData == null ? 'Add New Book' : 'Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              TextFormField(
                controller: _imgUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter an image URL'
                            : null,
              ),
              TextFormField(
                controller: _pdfUrlController,
                decoration: const InputDecoration(labelText: 'PDF URL'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a PDF URL'
                            : null,
              ),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(
                  labelText: 'Class (Optional)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isUploading ? null : saveBook,
                child:
                    isUploading
                        ? CircularProgressIndicator()
                        : Text('Save Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
