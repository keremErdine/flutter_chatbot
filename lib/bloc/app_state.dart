part of 'app_bloc.dart';

enum Screen { aboutScreen, mainScreen }

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse,
      required this.screen});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;
  final Screen screen;

  factory AppState.initial() {
    return AppState(
        messages: [],
        documents: [],
        generatingResponse: false,
        screen: Screen.mainScreen);
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse,
      Screen? screen}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse,
        screen: screen ?? this.screen);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        messages: messages + list,
        documents: documents,
        generatingResponse: generatingResponse,
        screen: screen);
  }
}
