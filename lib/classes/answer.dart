enum AnswerSelection { A, B, C, D, E }

class Answer {
  const Answer(
      {required this.answerSelection,
      required this.answerText,
      required this.isCorrect});
  final AnswerSelection answerSelection;
  final String answerText;
  final bool isCorrect;
}
