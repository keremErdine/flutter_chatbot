part of 'app_bloc.dart';

enum Screen { aboutScreen, chatScreen, welcomeScreen, loadingScreen }

enum Temperature { direct, normal, high, extreme, overkill }

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse,
      required this.screen,
      required this.prefs,
      required this.apiKey,
      required this.temperature});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;
  final Screen screen;
  final String apiKey;
  final Temperature temperature;
  final Future<SharedPreferences> prefs;

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
        apiKey: "",
        temperature: Temperature.normal);
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse,
      Screen? screen,
      bool? appStartup,
      String? apiKey,
      Temperature? temperature}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse,
        screen: screen ?? this.screen,
        prefs: prefs,
        apiKey: apiKey ?? this.apiKey,
        temperature: temperature ?? this.temperature);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        messages: messages + list,
        documents: documents,
        generatingResponse: generatingResponse,
        screen: screen,
        prefs: prefs,
        apiKey: apiKey,
        temperature: temperature);
  }
}
