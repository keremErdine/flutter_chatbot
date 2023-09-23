part of 'app_bloc.dart';

class AppState {
  AppState({required this.filePaths, required this.messages, this.documents});
  final List<String> filePaths;
  final List<Message> messages;
  lang_chain.Document? documents;

  factory AppState.initial() {
    return AppState(
      filePaths: [],
      messages: [],
    );
  }

  AppState copyWith(
      {List<String>? filePaths,
      List<Message>? messages,
      lang_chain.Document? documents}) {
    return AppState(
        filePaths: filePaths ?? this.filePaths,
        messages: messages ?? this.messages,
        documents: documents ?? this.documents);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        filePaths: filePaths, messages: messages + list, documents: documents);
  }
}
