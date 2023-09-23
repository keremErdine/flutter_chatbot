enum Sender { user, bot }

class Message {
  const Message({required this.message, required this.sender});
  final String message;
  final Sender sender;
}
