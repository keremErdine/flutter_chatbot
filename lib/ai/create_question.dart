// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:flutter_chatbot/classes/answer.dart';
import 'package:flutter_chatbot/classes/question.dart';

Question? currentQuestion;

void createQuestion(
    {required String question,
    required String correctAnswerText,
    required List<String> wrongAnswerTexts}) {
  final List<Answer> answers = [];
  final List<AnswerSelection> usedSelections = [];
  int random = Random().nextInt(5);
  answers.add(Answer(
      answerSelection: AnswerSelection.values[random],
      answerText: correctAnswerText,
      isCorrect: true));
  usedSelections.add(AnswerSelection.values[random]);
  for (String answerText in wrongAnswerTexts) {
    while (true) {
      random = Random().nextInt(5);
      if (!usedSelections.contains(AnswerSelection.values[random])) {
        answers.add(Answer(
            answerSelection: AnswerSelection.values[random],
            answerText: answerText,
            isCorrect: false));
        break;
      }
    }
  }
  currentQuestion = Question(question: question, answers: answers);
}
