class Subject {
  final String id;
  final String name;
  final String imageUrl;

  Subject({required this.id, required this.name, required this.imageUrl});

  factory Subject.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Subject(
      id: id,
      name: data['name'] ?? "",
      imageUrl: data['imageUrl'],
    );
  }

  Map<dynamic, dynamic> toMap() => {'name': name, 'imageUrl': imageUrl};
}

class Kelas {
  final String id;
  final String name;

  Kelas({required this.id, required this.name});

  factory Kelas.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Kelas(id: id, name: data['name']);
  }

  Map<dynamic, dynamic> toMap() => {"id": id, 'name': name};
}
class Bab {
  final String id;
  final String kelasId;
  final String subjectId;
  final String kelasSubjectId;
  final List<Subab> subabs;
  final String imageUrl;
  final String summaryPdfUrl;
  final String title;
  final String diagnosticQuiz;
  final String summativeQuiz;
  final String ytLink;
  final String youtubeIntroduction;
  final String youtubeIntroductionTitle;
  final int order_index; // Added with snake_case to match Firebase convention

  Bab({
    required this.id,
    required this.kelasId,
    required this.subjectId,
    required this.kelasSubjectId,
    required this.subabs,
    required this.imageUrl,
    required this.summaryPdfUrl,
    required this.title,
    required this.diagnosticQuiz,
    required this.summativeQuiz,
    required this.ytLink,
    required this.youtubeIntroduction,
    required this.youtubeIntroductionTitle,
    required this.order_index, // Added new parameter
  });

  factory Bab.fromSnapshot(
    String id,
    Map<dynamic, dynamic> data,
    List<Subab> loadedSubabs,
  ) {
    return Bab(
      id: id,
      ytLink: data["ytLink"] ?? "",
      kelasSubjectId: data["kelasSubjectId"] ?? "",
      kelasId: data['kelas_id'] ?? "",
      subjectId: data['subject_id'] ?? "",
      subabs: loadedSubabs,
      imageUrl: data['imageUrl'] ?? "",
      summaryPdfUrl: data['summaryPdfUrl'] ?? "",
      title: data['title'] ?? "",
      diagnosticQuiz: data['diagnosticQuiz'] ?? "",
      summativeQuiz: data["summativeQuiz"] ?? "",
      youtubeIntroduction: data["youtube_introduction"] ?? "",
      youtubeIntroductionTitle: data["youtube_introduction_title"] ?? "",
      order_index: data['order_index'] ?? 0, // Added with null check
    );
  }

  Map<dynamic, dynamic> toMap() => {
    'kelas_id': kelasId,
    "ytLink": ytLink,
    "kelasSubjectId": kelasSubjectId,
    'subject_id': subjectId,
    'subabs': {for (var s in subabs) s.id: true},
    'imageUrl': imageUrl,
    'summaryPdfUrl': summaryPdfUrl,
    'title': title,
    "youtube_introduction_title": youtubeIntroductionTitle,
    "youtube_introduction": youtubeIntroduction,
    "diagnosticQuiz": diagnosticQuiz,
    "summativeQuiz": summativeQuiz,
    'order_index': order_index, // Added to map
  };
}

class Subab {
  final String id;
  final String kelasId;
  final String subjectId;
  final String babId;
  final String pdfUrl;
  final String title;
  final String ytLinkMaterial;
  final String ytLinkExercise;
  final String exerciseTitle;
  final int orderIndex; // Tambahkan field order_index

  Subab({
    required this.id,
    required this.kelasId,
    required this.subjectId,
    required this.babId,
    required this.pdfUrl,
    required this.title,
    required this.ytLinkMaterial,
    required this.ytLinkExercise,
    required this.exerciseTitle,
    required this.orderIndex, // Tambahkan parameter baru
  });

  factory Subab.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Subab(
      id: id,
      kelasId: data['kelas_id'] ?? '',
      subjectId: data['subject_id'] ?? '',
      babId: data['bab_id'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      title: data['title'] ?? '',
      ytLinkMaterial: data['youtube_material'] ?? '',
      ytLinkExercise: data["youtube_exercise"] ?? '',
      exerciseTitle: data['exercise_title'] ?? '',
      orderIndex:
          data['order_index'] ?? 0, // Handle null dengan default value 0
    );
  }

  Map<dynamic, dynamic> toMap() => {
    'kelas_id': kelasId,
    'subject_id': subjectId,
    'bab_id': babId,
    'pdfUrl': pdfUrl,
    'title': title,
    'youtube_material': ytLinkMaterial,
    'youtube_exercise': ytLinkExercise,
    'exercise_title': exerciseTitle,
    'order_index': orderIndex, // Tambahkan ke map
  };
}

class Quiz {
  final String id;
  final String type;
  final String target;
  final Map<dynamic, dynamic> questions;

  Quiz({
    required this.id,
    required this.type,
    required this.target,
    required this.questions,
  });

  factory Quiz.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Quiz(
      id: id,
      type: data['type'],
      target: data['target'],
      questions: (data['questions'] as Map<dynamic, dynamic>).map(
        (k, v) => MapEntry(k.toString(), v),
      ),
    );
  }

  Map<dynamic, dynamic> toMap() => {
    'type': type,
    'target': target,
    'questions': questions,
  };
}
