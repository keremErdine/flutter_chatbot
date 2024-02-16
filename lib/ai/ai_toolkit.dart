/*
import 'package:flutter_chatbot/ai/create_question.dart';
import 'package:langchain/langchain.dart';

final createQuestionTool = BaseTool.fromFunction(
  name: "Create_Question",
  description: "",
  func: (
    final Map<String, dynamic> toolInput,
  ) async {
    final String question = toolInput['question'];
    final String correctAnswerText = toolInput['correctAnswer'];
    final List<String> wrongAnswerTexts = toolInput['wrongAnswers'];
    createQuestion(
        question: question,
        correctAnswerText: correctAnswerText,
        wrongAnswerTexts: wrongAnswerTexts);
    return "You have succesfully created a question. You will not see this but when the student solves it, you will be informed.";
  },
  inputJsonSchema: const {
    'type': 'object',
    'properties': {
      'question': {
        'type': 'string',
        'description': 'The question to ask to the student.',
      },
      'correctAnswer': {
        'type': 'string',
        'description':
            'The correct answer of the question. MAKE SURE THIS IS THE CORRECT ANSWER.',
      },
      'wrongAnswers': {
        'type': 'list',
        'description':
            'The wrong answers to this question. THERE SHOULD BE 4 ELEMENTS IN THIS LIST AND MAKE SURE THESE ARE WRONG ANSWERS.'
      }
    },
    'required': ['query', 'correctAnswer', 'wrongAnswers'],
  },
);
*/