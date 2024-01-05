import 'package:flutter/material.dart';

class AnswerWidget extends StatelessWidget {
  const AnswerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor.withBlue(190),
      child: const Expanded(
          child: Row(
        children: [Icon(Icons.abc), Text("hi")],
      )),
    );
  }
}
