part of 'app_bloc.dart';

class AppEvent {
  const AppEvent();
}

class AppMessageWritten extends AppEvent {
  AppMessageWritten({required this.message});
  final Message message;
}

@immutable
class AppAIStartedGeneratingResponse extends AppEvent {}

@immutable
class AppAIFinishedGeneratingResponse extends AppEvent {}

class AppScreenChanged extends AppEvent {
  AppScreenChanged({required this.screen});
  final Screen screen;
}

@immutable
class AppChatHistoryCleared extends AppEvent {}

@immutable
class AppDataFromPrefsRead extends AppEvent {}

@immutable
class AppMessageAddedToFirestore extends AppEvent {
  const AppMessageAddedToFirestore();
}

class AppApiKeyEntered extends AppEvent {
  AppApiKeyEntered({required this.apiKey});
  final String apiKey;
}

class AppAITemperatureSelected extends AppEvent {
  AppAITemperatureSelected({required this.temperature});
  final Temperature temperature;
}

class AppUserLoggedIn extends AppEvent {
  AppUserLoggedIn({required this.email, required this.password});
  final String email;
  final String password;
}

class AppUserSignedUp extends AppEvent {
  AppUserSignedUp(
      {required this.email, required this.password, required this.userName});
  final String email;
  final String password;
  final String userName;
}

class AppAccountMenuPageChanged extends AppEvent {
  const AppAccountMenuPageChanged({required this.accountMenu});
  final AccountMenu accountMenu;
}

@immutable
class AppFirebaseDataRead extends AppEvent {}

@immutable
class AppUserLoggedOut extends AppEvent {}

class AppCreditsConsumed extends AppEvent {
  const AppCreditsConsumed({required this.text});
  final String text;
}
