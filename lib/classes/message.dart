enum Sender { user, bot }

class Message {
  Message({
    required this.context,
    required this.sender,
  });
  final String context;
  final Sender sender;
}
