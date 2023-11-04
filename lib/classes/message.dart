enum Sender { user, bot }

class Message {
  const Message({required this.context, required this.sender});
  final String context;
  final Sender sender;
}
