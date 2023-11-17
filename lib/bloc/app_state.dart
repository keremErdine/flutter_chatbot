part of 'app_bloc.dart';

enum Screen { aboutScreen, chatScreen, welcomeScreen, loadingScreen }

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse,
      required this.screen,
      required this.prefs,
      required this.userAPIKey});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;
  final Screen screen;
  final Future<SharedPreferences> prefs;
  final String userAPIKey;

  factory AppState.initial() {
    return AppState(
        messages: [
          Message(
              context:
                  "Aşağıdaki kutucuğa yazı yazarak soru sorunuz. Hocam Bot(Yapay Zeka) sorunu yanıtlamaya çalışacaktır.",
              sender: Sender.system),
        ],
        documents: [],
        generatingResponse: false,
        screen: Screen.loadingScreen,
        prefs: SharedPreferences.getInstance(),
        userAPIKey: "");
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse,
      Screen? screen,
      bool? appStartup,
      String? userAPIKey}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse,
        screen: screen ?? this.screen,
        prefs: prefs,
        userAPIKey: userAPIKey ?? this.userAPIKey);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        messages: messages + list,
        documents: documents,
        generatingResponse: generatingResponse,
        screen: screen,
        prefs: prefs,
        userAPIKey: userAPIKey);
  }
}
