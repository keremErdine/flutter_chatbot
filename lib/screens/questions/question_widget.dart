// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_chatbot/classes/question.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({super.key, required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.5),
      elevation: 0.01,
      child: Column(
        children: [
          Text(
            "Question",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(
            height: height * 0.07,
          ),
          Row(
            children: [Container()],
          ),
          Row(
            children: [Container()],
          ),
        ],
      ),
    );
  }
}
