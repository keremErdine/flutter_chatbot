part of 'app_bloc.dart';

class AppEvent {
  const AppEvent();
}

class AppMessageWritten extends AppEvent {
  const AppMessageWritten({required this.message});
  final Message message;
}

@immutable
class AppAIStartedGeneratingResponse extends AppEvent {
  const AppAIStartedGeneratingResponse();
}

@immutable
class AppAIFinishedGeneratingResponse extends AppEvent {
  const AppAIFinishedGeneratingResponse();
}

class AppScreenChanged extends AppEvent {
  const AppScreenChanged({required this.screen});
  final Screen screen;
}

@immutable
class AppChatHistoryCleared extends AppEvent {
  const AppChatHistoryCleared();
}

@immutable
class AppDataFromPrefsRead extends AppEvent {
  const AppDataFromPrefsRead();
}

@immutable
class AppMessageAddedToFirestore extends AppEvent {
  const AppMessageAddedToFirestore();
}

class AppApiKeyEntered extends AppEvent {
  const AppApiKeyEntered({required this.apiKey});
  final String apiKey;
}

class AppAITemperatureSelected extends AppEvent {
  const AppAITemperatureSelected({required this.temperature});
  final Temperature temperature;
}

class AppUserLoggedIn extends AppEvent {
  const AppUserLoggedIn({required this.email, required this.password});
  final String email;
  final String password;
}

class AppUserSignedUp extends AppEvent {
  const AppUserSignedUp(
      {required this.email, required this.password, required this.userName});
  final String email;
  final String password;
  final String userName;
}

class AppAccountMenuPageChanged extends AppEvent {
  const AppAccountMenuPageChanged({required this.accountMenu});
  final AccountMenu accountMenu;
}

class AppFirebaseDataRead extends AppEvent {
  const AppFirebaseDataRead({required this.credential});
  final UserCredential credential;
}

@immutable
class AppUserLoggedOut extends AppEvent {
  const AppUserLoggedOut();
}

class AppCreditsConsumed extends AppEvent {
  const AppCreditsConsumed({required this.text});
  final String text;
}

class AppShopMenuChanged extends AppEvent {
  const AppShopMenuChanged({required this.menu});
  final ShopMenu menu;
}

class AppCreditsPurchased extends AppEvent {
  const AppCreditsPurchased({required this.type});
  final CreditType type;
}
