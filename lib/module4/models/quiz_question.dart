class QuizQuestion {
  final int quizId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String? difficulty;
  final String? solution;

  QuizQuestion({
    required this.quizId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.difficulty,
    this.solution,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      quizId: int.tryParse('${json['quiz_id'] ?? json['id'] ?? 0}') ?? 0,
      question: '${json['question'] ?? ''}',
      optionA: '${json['option_a'] ?? ''}',
      optionB: '${json['option_b'] ?? ''}',
      optionC: '${json['option_c'] ?? ''}',
      optionD: '${json['option_d'] ?? ''}',
      correctAnswer: '${json['correct_answer'] ?? ''}',
      difficulty: json['difficulty']?.toString(),
      solution: json['solution']?.toString(),
    );
  }

  String optionText(String option) {
    switch (option) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }
}
