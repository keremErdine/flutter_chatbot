import 'package:flutter_chatbot/classes/answer.dart';

class Question {
  const Question({required this.question, required this.answers});
  final String question;
  final List<Answer> answers;
}
