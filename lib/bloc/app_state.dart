part of 'app_bloc.dart';

class AppState {
  AppState(
      {required this.aiContext,
      required this.messages,
      required this.documents});
  final String aiContext;
  final List<Message> messages;
  final List<lang_chain.Document> documents;

  factory AppState.initial() {
    return AppState(aiContext: "", messages: [], documents: []);
  }

  AppState copyWith(
      {String? aiContext,
      List<Message>? messages,
      List<lang_chain.Document>? documents}) {
    return AppState(
        aiContext: aiContext ?? this.aiContext,
        messages: messages ?? this.messages,
        documents: documents ?? this.documents);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        aiContext: aiContext, messages: messages + list, documents: documents);
  }
}
