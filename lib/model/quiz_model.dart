enum QuestionType { MSA, SSA, ESSAY }
class WiidgetOption {
  final String? text;
  final bool? isCorrect;
  final int index; // Add index property

  const WiidgetOption({
    this.text, 
    this.isCorrect,
    required this.index, // Required index
  });

  factory WiidgetOption.fromJson(
    Map<dynamic, dynamic> json,
    int correctAnswerIndex,
    int index, // This is the option's index
  ) {
    return WiidgetOption(
      text: json['option'] ?? '',
      isCorrect: index == correctAnswerIndex,
      index: index, // Store the index
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'option': text,
      'isCorrect': isCorrect,
      'index': index,
    };
  }
}

class WidgetQuestion {
  final String htmlText;
  final String pembahasan;
  final QuestionType type;
  final List<WiidgetOption> options;
  WiidgetOption? selectedWiidgetOption;
  final List<String>? keywords;
  final Map<dynamic, double>? keywordWeights;
  String? userAnswer;
  final int correctAnswerIndex;

  WidgetQuestion({
    required this.htmlText,
    required this.pembahasan,
    required this.type,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedWiidgetOption,
    this.keywords,
    this.keywordWeights,
    this.userAnswer = "",
  });

  factory WidgetQuestion.fromJson(Map<dynamic, dynamic> json) {
    final questionType = _parseQuestionType(json['questionType']);
    final correctAnswerIndex = json['correct_answer'] is int 
        ? (json['correct_answer'] as int) - 1 // Convert to 0-based index
        : 0;

    List<WiidgetOption> generatedOptions = List<WiidgetOption>.generate(
      (json['options'] as List).length,
      (index) => WiidgetOption.fromJson(
        json['options'][index],
        correctAnswerIndex,
        index,
      ),
    );

    return WidgetQuestion(
      htmlText: json['question'] ?? '',
      pembahasan: json['pembahasan'] ?? '',
      type: questionType,
      options: generatedOptions,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  bool isAnswerCorrect(int? selectedIndex) {
    if (selectedIndex == null) return false;
    return selectedIndex == correctAnswerIndex;
  }

  static QuestionType _parseQuestionType(String type) {
    switch (type) {
      case 'MSA':
        return QuestionType.MSA;
      case 'SSA':
        return QuestionType.SSA;
      case 'ESSAY':
        return QuestionType.ESSAY;
      default:
        return QuestionType.MSA;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'question': htmlText,
      'pembahasan': pembahasan,
      'questionType': type.toString(),
      'options': options.map((option) => option.toMap()).toList(),
      'correct_answer': correctAnswerIndex + 1, // Convert back to 1-based index
    };
  }
}

class FullQuizModel {
  final String quiz;
  final List<WidgetQuestion> questions;
  final Map<String, dynamic>? data;

  FullQuizModel({
    required this.quiz,
    required this.questions,
    this.data,
  });

  factory FullQuizModel.fromJson(Map<dynamic, dynamic> json) {
    List<WidgetQuestion> shuffledQuestions =
        (json['questions'] as List).map((e) => WidgetQuestion.fromJson(e)).toList();

    return FullQuizModel(
      quiz: json["quiz"]["title"],
      questions: shuffledQuestions,
      data: json["data"] != null ? Map<String, dynamic>.from(json["data"]) : null,
    );
  }

  QuizResultModel calculateResult(List<int?> userAnswers) {
    if (questions.length != userAnswers.length) {
      throw ArgumentError("Number of answers doesn't match number of questions");
    }

    int correctCount = 0;
    final typeStats = <QuestionType, TypeStat>{};

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      final isCorrect = question.isAnswerCorrect(userAnswer);

      if (isCorrect) {
        correctCount++;
      }

      typeStats.update(
        question.type,
        (stat) => stat..update(isCorrect),
        ifAbsent: () => TypeStat()..update(isCorrect),
      );
    }

    final passingGrade = data?['cutoff'] ?? 60.0;
    final score = (correctCount / questions.length) * 100;

    return QuizResultModel(
      score: score,
      isPassed: score >= passingGrade,
      correctCount: correctCount,
      totalQuestions: questions.length,
      typeStatistics: typeStats,
      passingGrade: passingGrade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quiz': {
        'title': quiz,
        'description': data?['description'] ?? '',
      },
      'questions': questions.map((q) => q.toMap()).toList(),
      'data': data,
    };
  }
}

class TypeStat {
  int correct = 0;
  int total = 0;

  void update(bool isCorrect) {
    total++;
    if (isCorrect) correct++;
  }

  double get percentage => total > 0 ? (correct / total) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'correct': correct,
      'total': total,
      'percentage': percentage,
    };
  }
}

class QuizResultModel {
  final double score;
  final bool isPassed;
  final int correctCount;
  final int totalQuestions;
  final Map<QuestionType, TypeStat> typeStatistics;
  final double passingGrade;

  QuizResultModel({
    required this.score,
    required this.isPassed,
    required this.correctCount,
    required this.totalQuestions,
    required this.typeStatistics,
    required this.passingGrade,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'isPassed': isPassed,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'passingGrade': passingGrade,
      'typeStatistics': typeStatistics.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    };
  }
}