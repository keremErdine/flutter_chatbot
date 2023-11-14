enum Sender { user, bot, system }

class Message {
  Message({
    required this.context,
    required this.sender,
  });
  final String context;
  final Sender sender;
}
