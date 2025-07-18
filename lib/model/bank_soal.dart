class BankSoal {
  final String id; // Add this
  final String kelasSubjectId;
  final String kelasId;
  final String quizLink;
  final String title;

  BankSoal({
    this.id = '', // Add this with default empty string
    required this.kelasSubjectId,
    required this.kelasId,
    required this.quizLink,
    required this.title,
  });

  // Update fromMap to include id
  factory BankSoal.fromMap(Map<dynamic, dynamic> map) {
    return BankSoal(
      id: map['id'] ?? '', // Add this
      kelasSubjectId: map['kelasSubjectId'] ?? '',
      kelasId: map['kelas_id'] ?? '',
      quizLink: map['quiz_link'] ?? '',
      title: map['title'] ?? '',
    );
  }

  // toMap doesn't need id as it's the Firebase key
  Map<String, dynamic> toMap() {
    return {
      'kelasSubjectId': kelasSubjectId,
      'kelas_id': kelasId,
      'quiz_link': quizLink,
      'title': title,
    };
  }
}