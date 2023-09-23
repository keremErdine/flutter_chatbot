import 'package:flutter/material.dart';
import 'package:flutter_chatbot/classes/message.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget(
      {super.key, required this.message, this.forceBotMessage = false});
  final Message message;
  final bool forceBotMessage;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color color = Colors.blueAccent.shade100;
    TextAlign align = TextAlign.left;

    if (message.sender == Sender.user && !forceBotMessage) {
      color = Colors.lightGreenAccent;
      align = TextAlign.right;
    }

    return Row(children: <Widget>[
      if (message.sender == Sender.user && !forceBotMessage) const Spacer(),
      if (message.sender == Sender.bot || forceBotMessage)
        const Icon(
          Icons.smart_toy_outlined,
          color: Colors.blue,
        ),
      Card(
        color: color,
        child: SizedBox(
          width: width * 20 / 100,
          child: Text(
            message.message,
            textAlign: align,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      if (message.sender == Sender.user && !forceBotMessage)
        const Icon(
          Icons.person,
          color: Colors.lightGreenAccent,
        ),
      if (message.sender == Sender.bot || forceBotMessage) const Spacer(),
    ]);
  }
}
