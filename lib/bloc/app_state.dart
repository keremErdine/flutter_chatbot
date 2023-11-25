part of 'app_bloc.dart';

enum Screen { aboutScreen, chatScreen, welcomeScreen, loadingScreen }

enum Temperature { direct, normal, high, extreme, overkill }

enum AccountMenu { login, signup }

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse,
      required this.screen,
      required this.prefs,
      required this.apiKey,
      required this.temperature,
      required this.currentAcountMenu,
      required this.credential,
      required this.loggedIn,
      required this.userName});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;
  final Screen screen;
  final String apiKey;
  final Temperature temperature;
  final Future<SharedPreferences> prefs;
  final AccountMenu currentAcountMenu;
  final bool loggedIn;
  final String userName;
  UserCredential? credential;

  factory AppState.initial() {
    return AppState(
        messages: [
          Message(
            context: "Hocam Bot'u kullanmaya başlamak için giriş yapın.",
            sender: Sender.system,
          ),
        ],
        documents: [],
        generatingResponse: false,
        screen: Screen.loadingScreen,
        prefs: SharedPreferences.getInstance(),
        apiKey: "",
        temperature: Temperature.normal,
        currentAcountMenu: AccountMenu.login,
        credential: null,
        loggedIn: false,
        userName: "");
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse,
      Screen? screen,
      bool? appStartup,
      String? apiKey,
      Temperature? temperature,
      AccountMenu? currentAcountMenu,
      UserCredential? credential,
      bool? loggedIn,
      String? userName}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse,
        screen: screen ?? this.screen,
        prefs: prefs,
        apiKey: apiKey ?? this.apiKey,
        temperature: temperature ?? this.temperature,
        currentAcountMenu: currentAcountMenu ?? this.currentAcountMenu,
        credential: credential ?? this.credential,
        loggedIn: loggedIn ?? this.loggedIn,
        userName: userName ?? this.userName);
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
        temperature: temperature,
        currentAcountMenu: currentAcountMenu,
        credential: credential,
        loggedIn: loggedIn,
        userName: userName);
  }
}
