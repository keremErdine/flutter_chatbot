part of 'app_bloc.dart';

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;

  factory AppState.initial() {
    return AppState(messages: [], documents: [], generatingResponse: false);
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        messages: messages + list,
        documents: documents,
        generatingResponse: generatingResponse);
  }
}
