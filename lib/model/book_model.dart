class Book {
  final String id; // Added id property
  final String imgUrl;
  final String pdfUrl;
  final String title;
  final String? kelas; // Optional for universal books

  Book({
    required this.id,
    required this.imgUrl,
    required this.pdfUrl,
    required this.title,
    this.kelas,
  });

  // Convert Firebase snapshot to Book object
  factory Book.fromSnapshot(
    Map<dynamic, dynamic> snapshot, {
    bool isUniversal = false,
  }) {
    return Book(
      id: snapshot['id'] ?? '', // Ensure the 'id' field exists in Firebase data
      imgUrl: snapshot['imgUrl'] ?? '',
      pdfUrl: snapshot['pdfUrl'] ?? '',
      title: snapshot['title'] ?? '',
      kelas:
          !isUniversal
              ? snapshot['kelas']
              : null, // Optional class for non-universal books
    );
  }

  // Convert Book object to map for saving to Firebase
  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'imgUrl': imgUrl,
      'pdfUrl': pdfUrl,
      'title': title,
      'kelas': kelas, // Include kelas only if it's not null
    };
  }
}
