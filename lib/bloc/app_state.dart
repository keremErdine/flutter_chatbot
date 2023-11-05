part of 'app_bloc.dart';

class AppState {
  AppState({required this.messages, required this.documents});

  final List<Message> messages;
  final List<lang_chain.Document> documents;

  factory AppState.initial() {
    return AppState(messages: [], documents: []);
  }

  AppState copyWith(
      {List<Message>? messages, List<lang_chain.Document>? documents}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(messages: messages + list, documents: documents);
  }
}
