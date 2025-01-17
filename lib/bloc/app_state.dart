part of 'app_bloc.dart';

enum Screen { aboutScreen, chatScreen, welcomeScreen, loadingScreen }

enum Temperature { direct, normal, high, extreme, overkill }

enum AccountMenu { login, signup }

enum AccountLevel { free, associate, professor }

enum ShopMenu { credits, levels }

class AppState {
  AppState(
      {required this.messages,
      required this.documents,
      required this.generatingResponse,
      required this.screen,
      required this.prefs,
      required this.temperature,
      required this.currentAcountMenu,
      required this.credential,
      required this.loggedIn,
      required this.userName,
      required this.credits,
      required this.accountLevel,
      required this.currentShopMenu});

  final List<Message> messages;
  final List<lang_chain.Document> documents;
  final bool generatingResponse;
  final Screen screen;
  final Temperature temperature;
  final Future<SharedPreferences> prefs;
  final AccountMenu currentAcountMenu;
  final bool loggedIn;
  final String userName;
  final int credits;
  final AccountLevel accountLevel;
  final ShopMenu currentShopMenu;
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
        credits: 0,
        generatingResponse: false,
        screen: Screen.loadingScreen,
        prefs: SharedPreferences.getInstance(),
        temperature: Temperature.normal,
        currentAcountMenu: AccountMenu.login,
        credential: null,
        loggedIn: false,
        userName: "",
        accountLevel: AccountLevel.free,
        currentShopMenu: ShopMenu.credits);
  }

  AppState copyWith(
      {List<Message>? messages,
      List<lang_chain.Document>? documents,
      bool? generatingResponse,
      Screen? screen,
      bool? appStartup,
      Temperature? temperature,
      AccountMenu? currentAcountMenu,
      UserCredential? credential,
      bool? loggedIn,
      String? userName,
      int? credits,
      AccountLevel? accountLevel,
      ShopMenu? currentShopMenu}) {
    return AppState(
        messages: messages ?? this.messages,
        documents: documents ?? this.documents,
        generatingResponse: generatingResponse ?? this.generatingResponse,
        screen: screen ?? this.screen,
        prefs: prefs,
        temperature: temperature ?? this.temperature,
        currentAcountMenu: currentAcountMenu ?? this.currentAcountMenu,
        credential: credential ?? this.credential,
        loggedIn: loggedIn ?? this.loggedIn,
        userName: userName ?? this.userName,
        credits: credits ?? this.credits,
        accountLevel: accountLevel ?? this.accountLevel,
        currentShopMenu: currentShopMenu ?? this.currentShopMenu);
  }

  AppState addMessage(Message message) {
    List<Message> list = [message];
    return AppState(
        messages: messages + list,
        documents: documents,
        generatingResponse: generatingResponse,
        screen: screen,
        prefs: prefs,
        temperature: temperature,
        currentAcountMenu: currentAcountMenu,
        credential: credential,
        loggedIn: loggedIn,
        userName: userName,
        credits: credits,
        accountLevel: accountLevel,
        currentShopMenu: currentShopMenu);
  }
}
