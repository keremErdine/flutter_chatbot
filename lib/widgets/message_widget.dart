import 'package:flutter/material.dart';
import 'package:flutter_chatbot/classes/message.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
  });
  final Message message;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color color = Colors.lightGreenAccent;

    TextAlign align = TextAlign.right;

    if (message.sender == Sender.bot) {
      color = Colors.blueAccent.shade100;
      align = TextAlign.left;
    } else if (message.sender == Sender.system) {
      color = Colors.redAccent.shade400;
      align = TextAlign.left;
    }

    return Row(children: <Widget>[
      if (message.sender == Sender.user) const Spacer(),
      if (message.sender == Sender.bot)
        const Icon(
          Icons.smart_toy_outlined,
          color: Colors.blue,
        ),
      if (message.sender == Sender.system)
        Icon(
          Icons.settings,
          color: Colors.redAccent.shade400,
        ),
      Card(
        color: color,
        child: SizedBox(
          width: width * 20 / 100,
          child: Column(
            children: [
              Text(
                message.context,
                textAlign: align,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      if (message.sender == Sender.user)
        const Icon(
          Icons.person,
          color: Colors.lightGreenAccent,
        ),
      if (message.sender == Sender.bot || message.sender == Sender.system)
        const Spacer(),
    ]);
  }
}
